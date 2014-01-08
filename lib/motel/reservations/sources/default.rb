require 'active_record'

module Motel
  module Reservations
    module Sources

      class Default

        def tenants
          ActiveRecord::Base.configurations
        end

        def tenant(name)
          ActiveRecord::Base.configurations[name]
        end

        def tenant?(name)
          ActiveRecord::Base.configurations.key?(name)
        end

        def add_tenant(name, spec)
          raise ExistingTenantError if tenant?(name)

          ActiveRecord::Base.configurations[name] = keys_to_string(spec)
        end

        def update_tenant(name, spec)
          raise NonexistentTenantError unless tenant?(name)

          spec = keys_to_string(spec)
          spec = ActiveRecord::Base.configurations[name].merge(spec)
          ActiveRecord::Base.configurations[name] = spec
        end

        def delete_tenant(name)
          ActiveRecord::Base.configurations.delete(name)
        end

        private

          def keys_to_string(hash)
            hash = hash.inject({}) do |h, (k, v)|
              h[k.to_s] = v
              h
            end
          end

      end

    end
  end
end

