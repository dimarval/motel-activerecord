require 'active_record'

module Motel
  module Sources

    class Default

      attr_accessor :tenants

      def initialize(config = {})
        @tenants = config || {}
      end

      def tenant(name)
        tenants[name]
      end

      def tenant?(name)
        tenants.key?(name)
      end

      def add_tenant(name, spec)
        raise ExistingTenantError if tenant?(name)

        tenants[name] = keys_to_string(spec)
      end

      def update_tenant(name, spec)
        raise NonexistentTenantError unless tenant?(name)

        spec = keys_to_string(spec)
        tenants[name].merge!(spec)
      end

      def delete_tenant(name)
        tenants.delete(name)
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

