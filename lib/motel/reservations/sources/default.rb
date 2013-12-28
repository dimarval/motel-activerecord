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
        end

        def delete_tenant(name)
          ActiveRecord::Base.configurations.delete(name)
        end

      end

    end
  end
end

