module Motel
  module Reservations
    module Sources

      class Base

        def tenants
          raise NoMethodError, "Undefined method"
        end

        def tenant(name)
          raise NoMethodError, "Undefined method"
        end

        def tenant?(name)
          raise NoMethodError, "Undefined method"
        end

        def add_tenant(name, spec, expiration)
          raise NoMethodError, "Undefined method"
        end

        def update_tenant(name, spec, expiration)
          raise NoMethodError, "Undefined method"
        end

        def delete_tenant(name)
          raise NoMethodError, "Undefined method"
        end

        def tenant_expiration(name, expiration)
          raise NoMethodError, "Undefined method"
        end

        def create_tenant_table(table_name)
          raise NoMethodError, "Undefined method"
        end

        def destroy_tenant_table(table_name)
          raise NoMethodError, "Undefined method"
        end

      end

    end
  end
end

