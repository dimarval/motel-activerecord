require 'active_support/core_ext/hash/keys'
require 'motel'
require 'test/unit'

module Motel
  module Reservations
    module Sources

      class DataBaseTest < Test::Unit::TestCase

        def setup
          spec = { adapter: 'sqlite3', database: 'test/files/db/tenants.sqlite3' }
          resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(spec, nil)

          @current_tenant = 'test'
          @handler = Property::ConnectionHandler.new
          @handler.establish_connection(@current_tenant, resolver.spec)

          @table_name = 'tenants'
          @tenants_source = DataBase.new(source: spec, table_name: @table_name)
          @tenants_source.create_tenant_table

          @foo_tenant_sql = <<-SQL
            INSERT INTO #{@table_name}(`name`, `adapter`, `database`)
            VALUES ("foo", "sqlite3", "test/files/db/foo.sqlite3")
          SQL

          @bar_tenant_sql = <<-SQL
            INSERT INTO #{@table_name}(`name`, `adapter`, `database`)
            VALUES ("bar", "sqlite3", "test/files/db/bar.sqlite3")
          SQL
        end

        def teardown
          @tenants_source.destroy_tenant_table
        end

        def test_create_tenant_table
          assert @tenants_source.destroy_tenant_table
          assert @tenants_source.create_tenant_table
          assert @handler.retrieve_connection(@current_tenant).table_exists?(@table_name)
          assert @handler.retrieve_connection(@current_tenant).column_exists?(@table_name, :name, :string)
          assert @handler.retrieve_connection(@current_tenant).column_exists?(@table_name, :adapter, :string)
          assert @handler.retrieve_connection(@current_tenant).column_exists?(@table_name, :database, :string)
        end

        def test_destroy_table
          assert @tenants_source.destroy_tenant_table
          assert !@handler.retrieve_connection(@current_tenant).table_exists?(@table_name)
          assert @tenants_source.create_tenant_table
        end

        def test_tenants
          @handler.retrieve_connection_pool(@current_tenant).with_connection do |conn|
            conn.execute(@foo_tenant_sql)
            conn.execute(@bar_tenant_sql)
          end

          assert_equal 2, @tenants_source.tenants.count

          assert       @tenants_source.tenants.key?('foo')
          assert_equal @tenants_source.tenants['foo']['adapter'],  'sqlite3'
          assert_equal @tenants_source.tenants['foo']['database'], 'test/files/db/foo.sqlite3'

          assert       @tenants_source.tenants.key?('bar')
          assert_equal @tenants_source.tenants['bar']['adapter'],  'sqlite3'
          assert_equal @tenants_source.tenants['bar']['database'], 'test/files/db/bar.sqlite3'
        end

        def test_tenant?
          assert !@tenants_source.tenant?('foo')

          @handler.retrieve_connection_pool(@current_tenant).with_connection do |conn|
            conn.execute(@foo_tenant_sql)
          end

          assert @tenants_source.tenant?('foo')
        end

        def test_tenant
          @handler.retrieve_connection_pool(@current_tenant).with_connection do |conn|
            conn.execute(@foo_tenant_sql)
          end

          assert_equal @tenants_source.tenant('foo')['adapter'],  'sqlite3'
          assert_equal @tenants_source.tenant('foo')['database'], 'test/files/db/foo.sqlite3'
        end

        def test_add_no_existent_tenant
          @tenants_source.add_tenant('foo', { adapter: 'sqlite3', database: 'test/files/db/foo.sqlite3' })

          result = @handler.retrieve_connection_pool(@current_tenant).with_connection do |conn|
            conn.select_all("SELECT * FROM #{@table_name}")
          end

          assert_equal 1,                           result.count
          assert_equal 'foo',                       result.first['name']
          assert_equal 'sqlite3',                   result.first['adapter']
          assert_equal 'test/files/db/foo.sqlite3', result.first['database']
        end

        def test_add_existent_tenant
          @tenants_source.add_tenant('foo', { adapter: 'sqlite3', database: 'test/files/db/foo.sqlite3' })
          assert_raise ExistingTenantError do
            @tenants_source.add_tenant('foo', { adapter: 'sqlite3', database: 'test/files/db/foo.sqlite3' })
          end
        end

        def test_update_existent_tenant
          @handler.retrieve_connection_pool(@current_tenant).with_connection do |conn|
            conn.execute(@foo_tenant_sql)
          end

          @tenants_source.update_tenant('foo', { adapter: 'mysql2', database: 'bar' })

          result = @handler.retrieve_connection_pool(@current_tenant).with_connection do |conn|
            conn.select_all("SELECT * FROM #{@table_name} WHERE name = 'foo'")
          end

          assert_equal 'mysql2', result.first['adapter']
          assert_equal 'bar',    result.first['database']
        end

        def test_delete_tenant
          @handler.retrieve_connection_pool(@current_tenant).with_connection do |conn|
            conn.execute(@foo_tenant_sql)
          end

          assert @tenants_source.delete_tenant('foo')

          result = @handler.retrieve_connection_pool(@current_tenant).with_connection do |conn|
            conn.select_all("SELECT * FROM #{@table_name}")
          end

          assert_equal 0, result.count
        end

      end

    end
  end
end

