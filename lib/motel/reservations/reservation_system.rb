require 'active_support/core_ext/string/inflections'

module Motel
  module Reservations

    class ReservationSystem

      attr_accessor :source

      def initialize
        @source = Sources::Default.new
      end

      def source_configurations(source)
        source_class = "Motel::Reservations::Sources::#{source.to_s.camelize}".constantize

        source_instance = source_class.new

        yield source_instance if block_given?

        self.source = source_instance
      end

      def tenants
        source.tenants
      end

      def tenant(name)
        source.tenant(name)
      end

      def tenant?(name)
        source.tenant?(name)
      end

      def add_tenant(name, spec, expiration = nil)
        source.add_tenant(name, spec, expiration)
        tenant?(name)
      end

      def update_tenant(name, spec, expiration = nil)
        source.update_tenant(name, spec, expiration)
        tenant(name)
      end

      def delete_tenant(name)
        source.delete_tenant(name)
        !tenant?(name)
      end

      def create_tenant_table
        source.create_tenant_table
      end

      def destroy_tenant_table
        source.destroy_tenant_table
      end

    end

  end
end

