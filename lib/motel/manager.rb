require 'active_support/core_ext/module/attribute_accessors'
require 'active_record'

module Motel

  class Manager

    mattr_accessor :nonexistent_tenant_page
    mattr_accessor :admission_criteria
    mattr_accessor :default_tenant
    mattr_accessor :current_tenant

    def tenants_source_configurations(config)
      Motel::ReservationSystem.source_configurations(config)
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

    def add_tenant(name, spec)
      tenants_source.add_tenant(name, spec)
      tenant?(name)
    end

    def update_tenant(name, spec)
      tenants_source.update_tenant(name, spec)
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

    def tenants_source
      Motel::ReservationSystem.source
    end

    private

      def remove_tenant_connection(name)
        ActiveRecord::Base.remove_connection(name)
      end

  end

end

