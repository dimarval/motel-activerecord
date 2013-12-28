require 'active_support/core_ext/module/attribute_accessors'

module Motel

  class Manager

    mattr_accessor :disable_middleware
    mattr_accessor :nonexistent_tenant_page
    mattr_accessor :admission_criteria
    mattr_accessor :default_tenant
    mattr_accessor :current_tenant
    mattr_accessor :reservations

    def initialize
      @@disabled_middleware ||= false
      @@reservations ||= Reservations::Sources::Default.new
    end

    def source_configurations(source)
      source_class = "Motel::Reservations::Sources::#{source.to_s.camelize}".constantize
      source_instance = source_class.new

      yield source_instance if block_given?

      self.reservations = source_instance
    end

    def tenants
      reservations.tenants
    end

    def tenant(name)
      reservations.tenant(name)
    end

    def tenant?(name)
      active_tenants.include?(name) || reservations.tenant?(name)
    end

    def add_tenant(name, spec, expiration = nil)
      reservations.add_tenant(name, spec, expiration)
      tenant?(name)
    end

    def update_tenant(name, spec, expiration = nil)
      reservations.update_tenant(name, spec, expiration)
      remove_tenant_connection(name)
      tenant(name)
    end

    def delete_tenant(name)
      reservations.delete_tenant(name)
      remove_tenant_connection(name)
      !tenant?(name)
    end

    def create_tenant_table
      reservations.create_tenant_table
    end

    def destroy_tenant_table
      reservations.destroy_tenant_table
    end

    def active_tenants
      ActiveRecord::Base.connection_handler.active_tenants
    end

    def determines_tenant
        ENV['TENANT'] || current_tenant || default_tenant ||
          (raise NoCurrentTenantError)
    end

    private

      def remove_tenant_connection(name)
        ActiveRecord::Base.remove_connection(name)
      end

  end

end

