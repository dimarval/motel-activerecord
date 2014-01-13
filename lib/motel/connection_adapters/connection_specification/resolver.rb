require 'active_record'

module Motel
  module ConnectionAdapters
    module ConnectionSpecification
      class Resolver

        attr_accessor :tenants_source

        def initialize(tenants_source)
          @tenants_source = tenants_source
        end

        def spec(tenant_name)
          unless tenants_source.tenant?(tenant_name)
            raise NonexistentTenantError, "Nonexistent #{tenant_name} tenant"
          end

          spec = resolve(tenants_source.tenant(tenant_name)).symbolize_keys

          raise(ActiveRecord::AdapterNotSpecified, "database configuration does not specify adapter") unless spec.key?(:adapter)

          path_to_adapter = "active_record/connection_adapters/#{spec[:adapter]}_adapter"
          begin
            require path_to_adapter
          rescue Gem::LoadError => e
            raise Gem::LoadError, "Specified '#{spec[:adapter]}' for database adapter, but the gem is not loaded. Add `gem '#{e.name}'` to your Gemfile (and ensure its version is at the minimum required by ActiveRecord)."
          rescue LoadError => e
            raise LoadError, "Could not load '#{path_to_adapter}'. Make sure that the adapter in config/database.yml is valid. If you use an adapter other than 'mysql', 'mysql2', 'postgresql' or 'sqlite3' add the necessary adapter gem to the Gemfile.", e.backtrace
          end

          adapter_method = "#{spec[:adapter]}_connection"
          ActiveRecord::ConnectionAdapters::ConnectionSpecification.new(spec, adapter_method)
        end

        private

          def resolve(config)
            if config
              resolve_hash_connection config
            else
              raise ActiveRecord::AdapterNotSpecified
            end
          end

          def resolve_hash_connection(spec)
            if url = spec.delete("url")
              connection_hash = resolve_string_connection(url)
              spec.merge!(connection_hash)
            end
            spec
          end

      end
    end
  end
end
