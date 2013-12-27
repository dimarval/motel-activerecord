require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/inflections'
require 'motel'
require 'test/unit'

module Motel

  class ManagerTest < Test::Unit::TestCase

    def setup
      @manager = Manager.new
      @manager.source_configurations :data_base do |c|
        c.source = {adapter: 'sqlite3', database: './files/test.sqlite3'}
        c.table_name = 'tenants'
      end
      @source_data_base = @manager.reservations
      @manager.create_tenant_table
    end

    def teardown
      @manager.destroy_tenant_table
    end

    def test_source_configurations_for_data_base
      config ||= begin
        @manager.source_configurations :data_base do |c|
          c.source = {adapter: 'sqlite3', database: './files/test.sqlite3'}
          c.table_name = 'tenants'
        end
      end

      assert_instance_of Reservations::Sources::DataBase, config
    end

    def test_source_configurations_for_redis
      @manager.destroy_tenant_table
      config ||= begin
        @manager.source_configurations :redis do |c|
          c.host = 'localhost'
        end
      end

      assert_instance_of Reservations::Sources::Redis, config

      @manager.reservations = @source_data_base
      @manager.create_tenant_table
    end

    def test_tenants
      assert @manager.add_tenant('foo', {adapter: 'sqlite3', database: 'db/foo.sqlite3'})
      assert @manager.add_tenant('bar', {adapter: 'sqlite3', database: 'db/bar.sqlite3'})

      assert       @manager.tenants.key?('foo')
      assert_equal @manager.tenants['foo']['adapter'],  'sqlite3'
      assert_equal @manager.tenants['foo']['database'], 'db/foo.sqlite3'

      assert       @manager.tenants.key?('bar')
      assert_equal @manager.tenants['bar']['adapter'],  'sqlite3'
      assert_equal @manager.tenants['bar']['database'], 'db/bar.sqlite3'
    end

    def test_tenant
      assert @manager.add_tenant('foo', {adapter: 'sqlite3', database: 'db/foo.sqlite3'})

      assert_equal @manager.tenant('foo')['adapter'],  'sqlite3'
      assert_equal @manager.tenant('foo')['database'], 'db/foo.sqlite3'
    end

    def test_tenant?
      assert !@manager.tenant?('foo')
      assert @manager.add_tenant('foo', {adapter: 'sqlite3', database: 'db/foo.sqlite3'})
      assert @manager.tenant?('foo')
    end

    def test_add_tenant
      assert @manager.add_tenant('foo', {adapter: 'sqlite3', database: 'db/foo.sqlite3'})
    end

    def test_update_tenant
      assert @manager.add_tenant('foo', {adapter: 'sqlite3', database: 'db/foo.sqlite3'})
      assert @manager.update_tenant('foo', {adapter: 'sqlite3', database: 'db/bar.sqlite3'})
    end

    def test_delete_tenant
      assert @manager.add_tenant('foo', {adapter: 'sqlite3', database: 'db/foo.sqlite3'})
      assert @manager.delete_tenant('foo')
    end

    def tets_determines_tenant
      ENV['TENANT'] = 'foo'
      self.current_tenant = 'bar'
      self.default_tenant = 'baz'
      asser_equal 'foo', @manager.determines_tenant

      ENV['TENANT'] = nil
      asser_equal 'bar', @manager.determines_tenant

      self.current_tenant = nil
      asser_equal 'baz', @manager.determines_tenant
    end

  end

end

