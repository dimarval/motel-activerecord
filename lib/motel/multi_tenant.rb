module Motel
  module MultiTenant
    extend ActiveSupport::Concern

    included do

      mattr_accessor :motel, instance_writer: false
      self.default_connection_handler = ConnectionAdapters::ConnectionHandler.new
      self.motel = Manager

    end

    module ClassMethods

      def establish_connection(config)
        resolver = ConnectionAdapters::ConnectionSpecification::Resolver.new(motel.tenants)
        spec = resolver.spec(config)
        connection_handler.establish_connection (ENV['TENANT'] || self.name), spec
      end

      def connection_pool
        connection_handler.retrieve_connection_pool(current_tenant)
      end

      def retrieve_connection
        connection_handler.retrieve_connection(current_tenant)
      end

      def connected?
        connection_handler.connected?(current_tenant)
      end

      def remove_connection(tenant_name = current_tenant)
        connection_handler.remove_connection(tenant_name)
      end

      def arel_engine
        ActiveRecord::Base
      end

      def current_tenant
        motel.determines_tenant or raise Motel::NoCurrentTenantError
      end

    end
  end

end

ActiveSupport.on_load(:active_record) do
  include Motel::MultiTenant
end

