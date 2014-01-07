require 'active_record'

module Motel

  module Property

    class ConnectionHandler < ActiveRecord::ConnectionAdapters::ConnectionHandler

      attr_accessor :tenants_source

      def initialize(tenants_source = nil)
        @owner_to_pool = ThreadSafe::Cache.new(:initial_capacity => 2) do |h,k|
          h[k] = ThreadSafe::Cache.new(:initial_capacity => 2)
        end
        @class_to_pool = ThreadSafe::Cache.new(:initial_capacity => 2) do |h,k|
          h[k] = ThreadSafe::Cache.new
        end

        @tenants_source = tenants_source || Reservations::Sources::Default.new
      end

      def establish_connection(tenant_name, spec = nil)
        spec ||= connection_especification(tenant_name)
        @class_to_pool.clear
        owner_to_pool[tenant_name] = ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec)
      end

      def retrieve_connection(tenant_name)
        pool = retrieve_connection_pool(tenant_name)

        unless pool.connection
          establish_connection tenant_name
          pool = retrieve_connection_pool(tenant_name)
        end

        pool.connection
      end

      def retrieve_connection_pool(tenant_name)
        class_to_pool[tenant_name] ||= begin
          pool = pool_for(tenant_name)

          class_to_pool[tenant_name] = pool
        end
      end

      def remove_connection(tenant_name)
        if pool = owner_to_pool.delete(tenant_name)
          @class_to_pool.clear
          pool.automatic_reconnect = false
          pool.disconnect!
          pool.spec.config
        end
      end

      def pool_for(tenant_name)
        owner_to_pool.fetch(tenant_name) {
          establish_connection tenant_name
        }
      end

      def pool_from_any_process_for(tenant_name)
        owner_to_pool = @owner_to_pool.values.find { |v| v[tenant_name] }
        owner_to_pool && owner_to_pool[tenant_name]
      end

      def active_tenants
         owner_to_pool.keys
      end

      private

        def connection_especification(tenant_name)
          unless tenants_source.tenant?(tenant_name)
            raise NonexistentTenantError, "Nonexistent #{tenant_name} tenant"
          end

          resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(
            tenants_source.tenant(tenant_name), nil
          )
          spec = resolver.spec

          unless ActiveRecord::Base.respond_to?(spec.adapter_method)
            raise ActiveRecord::AdapterNotFound, "database configuration specifies nonexistent #{spec.config[:adapter]} adapter"
          end

          spec
        end

    end

  end

end

