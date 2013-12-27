require 'active_support/core_ext/hash/keys'
require './lib/motel'
require 'test/unit'

module Motel
  module Property

    class ConnectionHandlerTest < Test::Unit::TestCase

      def setup
        spec = { adapter: 'sqlite3', database: './test/files/test.sqlite3' }
        resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(spec, nil)

        @current_tenant = 'foo'

        @handler = ConnectionHandler.new
        @pool = @handler.establish_connection(@current_tenant, resolver.spec)
      end

      def test_retrieve_connection_from_an_existing_tenant
        assert_equal @handler.retrieve_connection(@current_tenant), @pool.connection
      end

      def test_retrieve_connection_from_an_nonexistent_tenant
        assert_raise(NonexistentTenantError){ @handler.retrieve_connection('bar') }
      end

      def test_active_connections?
        assert !@handler.active_connections?
        assert @handler.retrieve_connection(@current_tenant)
        assert @handler.active_connections?
        @handler.clear_active_connections!
        assert !@handler.active_connections?
      end

      def test_retrieve_connection_pool_from_an_existing_tenant
        assert @handler.retrieve_connection_pool(@current_tenant)
      end

      def test_retrieve_connection_from_an_nonexistent_tenant
        assert_raise(NonexistentTenantError){ @handler.retrieve_connection('bar') }
      end

    end

  end
end
