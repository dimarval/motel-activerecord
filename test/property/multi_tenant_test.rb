require 'motel'
require 'test/unit'

module Motel
  module Property

    class MultiTenantTest < Test::Unit::TestCase

      def setup
        ActiveRecord::Base.motel.add_tenant('foo', {adapter: 'sqlite3', database: 'test/files/db/foo.sqlite3'})
        ActiveRecord::Base.motel.add_tenant('bar', {adapter: 'sqlite3', database: 'test/files/db/bar.sqlite3'})

        @foo_pool = ActiveRecord::Base.establish_connection('foo')
        @bar_pool = ActiveRecord::Base.establish_connection('bar')
      end

      def test_connection_pool
        assert_raise NoCurrentTenantError do
          ActiveRecord::Base.connection_pool
        end

        ActiveRecord::Base.motel.current_tenant = 'baz'
        assert_raise NonexistentTenantError do
          ActiveRecord::Base.connection_pool
        end

        ActiveRecord::Base.motel.current_tenant = 'foo'
        assert_equal ActiveRecord::Base.connection_pool, @foo_pool

        ActiveRecord::Base.motel.current_tenant = 'bar'
        assert_equal ActiveRecord::Base.connection_pool, @bar_pool
      end

      def test_retrieve_connection
        assert_raise NoCurrentTenantError do
          ActiveRecord::Base.retrieve_connection
        end

        ActiveRecord::Base.motel.current_tenant = 'baz'
        assert_raise NonexistentTenantError do
          ActiveRecord::Base.retrieve_connection
        end

        ActiveRecord::Base.motel.current_tenant = 'foo'
        assert_equal ActiveRecord::Base.retrieve_connection, @foo_pool.connection

        ActiveRecord::Base.motel.current_tenant = 'bar'
        assert_equal ActiveRecord::Base.retrieve_connection, @bar_pool.connection
      end

      def test_remove_connection
        ActiveRecord::Base.remove_connection('foo')
        assert !ActiveRecord::Base.motel.active_tenants.include?('foo')
      end

      def test_arel_egine
        assert_same ActiveRecord::Base, ActiveRecord::Base.arel_engine
      end

      def teardown
        ENV['TENANT'] = nil
        ActiveRecord::Base.motel.default_tenant = nil
        ActiveRecord::Base.motel.current_tenant = nil

        ActiveRecord::Base.motel.delete_tenant('foo')
        ActiveRecord::Base.motel.delete_tenant('bar')
      end

    end

  end
end

