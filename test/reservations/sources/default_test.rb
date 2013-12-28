require 'motel'
require 'test/unit'

module Motel
  module Reservations
    module Sources

      class DefaultTest < Test::Unit::TestCase

        def setup
          ActiveRecord::Base.configurations['foo'] = {'adapter' => 'sqlite3', 'database' => 'test/files/db/foo.sqlite3'}
          ActiveRecord::Base.configurations['bar'] = {'adapter' => 'sqlite3', 'database' => 'test/files/db/bar.sqlite3'}

          @tenants_source = Sources::Default.new
        end

        def test_tenants
          assert_equal 2, @tenants_source.tenants.count

          assert       @tenants_source.tenants.key?('foo')
          assert_equal @tenants_source.tenants['foo']['adapter'],  'sqlite3'
          assert_equal @tenants_source.tenants['foo']['database'], 'test/files/db/foo.sqlite3'

          assert       @tenants_source.tenants.key?('bar')
          assert_equal @tenants_source.tenants['bar']['adapter'],  'sqlite3'
          assert_equal @tenants_source.tenants['bar']['database'], 'test/files/db/bar.sqlite3'
        end

        def test_tenant
          assert_equal @tenants_source.tenant('foo')['adapter'],  'sqlite3'
          assert_equal @tenants_source.tenant('foo')['database'], 'test/files/db/foo.sqlite3'
        end

        def test_tenant?
          assert @tenants_source.tenant?('foo')

          ActiveRecord::Base.configurations.delete('foo')
          assert !@tenants_source.tenant?('foo')
        end

        def test_add_tenant
          assert_raise ExistingTenantError do
            @tenants_source.add_tenant('foo', {adapter: 'sqlite3', database: 'test/files/db/foo.sqlite3'})
          end

          ActiveRecord::Base.configurations.delete('foo')
          @tenants_source.add_tenant('foo', {adapter: 'sqlite3', database: 'test/files/db/foo.sqlite3'})

          assert       ActiveRecord::Base.configurations.key?('foo')
          assert_equal ActiveRecord::Base.configurations['foo']['adapter'],  'sqlite3'
          assert_equal ActiveRecord::Base.configurations['foo']['database'], 'test/files/db/foo.sqlite3'
        end

        def test_update_tenant
          assert_raise NonexistentTenantError do
            @tenants_source.update_tenant('baz', {})
          end

          @tenants_source.update_tenant('foo', {adapter: 'mysql2', database: 'foo'})

          assert       ActiveRecord::Base.configurations.key?('foo')
          assert_equal ActiveRecord::Base.configurations['foo']['adapter'],  'mysql2'
          assert_equal ActiveRecord::Base.configurations['foo']['database'], 'foo'

          @tenants_source.update_tenant('bar', {database: 'test/files/db/bar_new_db.sqlite3'})

          assert       ActiveRecord::Base.configurations.key?('bar')
          assert_equal ActiveRecord::Base.configurations['bar']['adapter'],  'sqlite3'
          assert_equal ActiveRecord::Base.configurations['bar']['database'], 'test/files/db/bar_new_db.sqlite3'
        end

        def test_delete_tenant
          @tenants_source.delete_tenant('foo')
          assert !ActiveRecord::Base.configurations.key?('foo')
        end

        def teardown
          ActiveRecord::Base.configurations = {}
        end

      end

    end
  end
end

