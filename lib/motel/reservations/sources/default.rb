module Motel
  module Reservations
    module Sources

      class Default < Base

        def tenants
          ActiveRecord::Base.configurations
        end

        def tenant(name)
          ActiveRecord::Base.configurations[name]
        end

        def tenant?(name)
          ActiveRecord::Base.configurations.key?(name)
        end

        def add_tenant(name, spec, expiration)
          raise ExistingTenantError if tenant?(name)

          ActiveRecord::Base.configurations[name] = spec
        end

        def update_tenant(name, spec, expiration)
          raise NoExistingTenantError unless tenant?(name)

          ActiveRecord::Base.configurations[name] = spec
          remove_connection_tenant(name)
        end

        def delete_tenant(name)
          if ActiveRecord::Base.configurations.delete(name)
            remove_connection_tenant(name)
          end
        end

      end

    end
  end
end

