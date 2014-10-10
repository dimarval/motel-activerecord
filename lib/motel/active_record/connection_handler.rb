require 'active_record'
require 'active_support/concern'
require 'motel/connection_adapters'

module Motel
  module ActiveRecord
    module ConnectionHandler
      extend ActiveSupport::Concern

      included do

        self.default_connection_handler = Motel::ConnectionAdapters::ConnectionHandler.new

      end

      module ClassMethods

        def establish_connection(config)
          tenant_name = Motel::Manager.determines_tenant || self.name
          resolver    = Motel::ConnectionAdapters::ConnectionSpecification::Resolver.new
          spec        = resolver.spec(config)

          connection_handler.establish_connection tenant_name, spec
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
          ::ActiveRecord::Base
        end

        def current_tenant
          Motel::Manager.determines_tenant or raise Motel::NoCurrentTenantError
        end

      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include Motel::ActiveRecord::ConnectionHandler
end

