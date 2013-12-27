require 'redis'
require 'motel'
require 'test/unit'

module Motel
  module Reservations
    module Sources

      class RedisTest < Test::Unit::TestCase

        def setup
          @redis_server = ::Redis.new
          @prefix_tenant_alias = 'test-tenant:'
          @tenants_source = Sources::Redis.new(prefix_tenant_alias: @prefix_tenant_alias)
        end

        def test_tenants
          @redis_server.hset "#{@prefix_tenant_alias}foo", 'adapter',  'sqlite3'
          @redis_server.hset "#{@prefix_tenant_alias}foo", 'database', 'db/foo.sqlite3'
          @redis_server.hset "#{@prefix_tenant_alias}bar", 'adapter',  'sqlite3'
          @redis_server.hset "#{@prefix_tenant_alias}bar", 'database', 'db/bar.sqlite3'

          assert_equal 2, @tenants_source.tenants.count

          assert       @tenants_source.tenants.key?('foo')
          assert_equal @tenants_source.tenants['foo']['adapter'],  'sqlite3'
          assert_equal @tenants_source.tenants['foo']['database'], 'db/foo.sqlite3'

          assert       @tenants_source.tenants.key?('bar')
          assert_equal @tenants_source.tenants['bar']['adapter'],  'sqlite3'
          assert_equal @tenants_source.tenants['bar']['database'], 'db/bar.sqlite3'

          @redis_server.hdel "#{@prefix_tenant_alias}foo", 'adapter'
          @redis_server.hdel "#{@prefix_tenant_alias}foo", 'database'
          @redis_server.hdel "#{@prefix_tenant_alias}bar", 'adapter'
          @redis_server.hdel "#{@prefix_tenant_alias}bar", 'database'
        end

        def test_tenant
          @redis_server.hset "#{@prefix_tenant_alias}foo", 'adapter',  'sqlite3'
          @redis_server.hset "#{@prefix_tenant_alias}foo", 'database', 'db/foo.sqlite3'

          assert_equal @tenants_source.tenants['foo']['adapter'],  'sqlite3'
          assert_equal @tenants_source.tenants['foo']['database'], 'db/foo.sqlite3'

          @redis_server.hdel "#{@prefix_tenant_alias}foo", 'adapter'
          @redis_server.hdel "#{@prefix_tenant_alias}foo", 'database'
        end

        def test_tenant?
          assert !@tenants_source.tenant?('foo')
          @redis_server.hset "#{@prefix_tenant_alias}foo", 'adapter',  'sqlite3'
          assert @tenants_source.tenant?('foo')
          @redis_server.hdel "#{@prefix_tenant_alias}foo", 'adapter'
          assert !@tenants_source.tenant?('foo')
        end

        def test_add_tenant
          @tenants_source.add_tenant('foo', { adapter: 'sqlite3', database: 'db/foo.sqlite3' })
          assert_equal @redis_server.hget("#{@prefix_tenant_alias}foo", 'adapter'),  'sqlite3'
          assert_equal @redis_server.hget("#{@prefix_tenant_alias}foo", 'database'), 'db/foo.sqlite3'
          assert_raise ExistingTenantError do
            @tenants_source.add_tenant('foo', { adapter: 'sqlite3', database: 'db/foo.sqlite3' })
          end

          @redis_server.hdel "#{@prefix_tenant_alias}foo", 'adapter'
          @redis_server.hdel "#{@prefix_tenant_alias}foo", 'database'
        end

        def test_update_tenant
          assert_raise NonexistentTenantError do
            @tenants_source.update_tenant('foo', { adapter: 'sqlite3', database: 'db/foo.sqlite3' })
          end

          @redis_server.hset "#{@prefix_tenant_alias}foo", 'adapter',  'sqlite3'
          @redis_server.hset "#{@prefix_tenant_alias}foo", 'database', 'db/foo.sqlite3'
          @tenants_source.update_tenant('foo', { adapter: 'mysql2', database: 'db/bar.sqlite3' })

          assert_equal @redis_server.hget("#{@prefix_tenant_alias}foo", 'adapter'),  'mysql2'
          assert_equal @redis_server.hget("#{@prefix_tenant_alias}foo", 'database'), 'db/bar.sqlite3'

          @redis_server.hdel "#{@prefix_tenant_alias}foo", 'adapter'
          @redis_server.hdel "#{@prefix_tenant_alias}foo", 'database'
        end

        def test_delete_tenant
          @redis_server.hset "#{@prefix_tenant_alias}foo", 'adapter',  'sqlite3'
          @redis_server.hset "#{@prefix_tenant_alias}foo", 'database', 'db/foo.sqlite3'

          @tenants_source.delete_tenant('foo')

          assert !@redis_server.hexists("#{@prefix_tenant_alias}foo", 'adapter')
          assert !@redis_server.hexists("#{@prefix_tenant_alias}foo", 'database')
        end

      end

    end
  end
end

