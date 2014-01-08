require 'active_support/core_ext/module/attribute_accessors'
require 'active_record'

module Motel

  class Manager

    mattr_accessor :nonexistent_tenant_page
    mattr_accessor :admission_criteria
    mattr_accessor :default_tenant
    mattr_accessor :current_tenant
    mattr_accessor :tenants_source

    def initialize
      @@tenants_source ||= ActiveRecord::Base.connection_handler.tenants_source
    end

    def tenants_source_configurations(source_type, config = {})
      self.tenants_source = Reservations::ReservationSystem.source(source_type, config)
      ActiveRecord::Base.connection_handler.tenants_source = tenants_source
    end

    def tenants
      tenants_source.tenants
    end

    def tenant(name)
      tenants_source.tenant(name)
    end

    def tenant?(name)
      active_tenants.include?(name) || tenants_source.tenant?(name)
    end

    def add_tenant(name, spec, expiration = nil)
      tenants_source.add_tenant(name, spec, expiration)
      tenant?(name)
    end

    def update_tenant(name, spec, expiration = nil)
      tenants_source.update_tenant(name, spec, expiration)
      remove_tenant_connection(name)
      tenant(name)
    end

    def delete_tenant(name)
      tenants_source.delete_tenant(name)
      remove_tenant_connection(name)
      !tenant?(name)
    end

    def create_tenant_table
      tenants_source.create_tenant_table
    end

    def destroy_tenant_table
      tenants_source.destroy_tenant_table
    end

    def active_tenants
      ActiveRecord::Base.connection_handler.active_tenants
    end

    def determines_tenant
      ENV['TENANT'] || current_tenant || default_tenant
    end

    private

      def remove_tenant_connection(name)
        ActiveRecord::Base.remove_connection(name)
      end

  end

end

