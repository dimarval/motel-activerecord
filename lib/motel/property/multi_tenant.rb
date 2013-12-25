module Motel
  module Property
    module MultiTenant
      extend ActiveSupport::Concern

      included do

        mattr_accessor :motel, instance_writer: false
        self.motel = Manager.new
        self.default_connection_handler = Property::ConnectionHandler.new

      end

      module ClassMethods

        def establish_connection(tenant_name)
          resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(
            motel.tenant(tenant_name), nil
          )
          spec = resolver.spec

          unless respond_to?(spec.adapter_method)
            raise AciveRecord::AdapterNotFound, "database configuration specifies nonexistent #{spec.config[:adapter]} adapter"
          end

          connection_handler.establish_connection tenant_name, spec
        end

        def connection_pool
          connection_handler.retrieve_connection_pool(motel.determines_tenant) or raise ActiveRecord::ConnectionNotEstablished
        end

        def retrieve_connection
          connection_handler.retrieve_connection(motel.determines_tenant)
        end

        def connected?
          connection_handler.connected?(motel.determines_tenant)
        end

        def remove_connection(tenant_name = motel.determines_tenant)
          connection_handler.remove_connection(tenant_name)
        end

        def arel_engine
          ActiveRecord::Base
        end

      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include Motel::Property::MultiTenant
end

