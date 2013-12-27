require 'active_record'

module Motel

  module Property

    class ConnectionHandler < ActiveRecord::ConnectionAdapters::ConnectionHandler

      def establish_connection(tenant_name, spec)
        @class_to_pool.clear
        raise AnonymousTenantError unless tenant_name
        owner_to_pool[tenant_name] = ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec)
      end

      def retrieve_connection(tenant_name)
        pool = retrieve_connection_pool(tenant_name)

        unless (pool && pool.connection)
          initialize_connection(tenant_name)
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
          if ancestor_pool = pool_from_any_process_for(tenant_name)
            # A connection was established in an ancestor process that must have
            # subsequently forked. We can't reuse the connection, but we can copy
            # the specification and establish a new connection with it.
            establish_connection tenant_name, ancestor_pool.spec
          else
            initialize_connection(tenant_name)
          end
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

        def initialize_connection(tenant_name)
          spec = connection_especification(tenant_name)
          establish_connection tenant_name, spec
        end

        def connection_especification(tenant_name)
          unless ActiveRecord::Base.motel.tenant?(tenant_name)
            raise NonexistentTenantError, "Nonexistent #{tenant_name} tenant"
          end

          resolver =  ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(
            ActiveRecord::Base.motel.tenant(tenant_name), nil
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

