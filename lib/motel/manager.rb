require 'active_support/core_ext/module/attribute_accessors'
require 'active_record'

module Motel

  class Manager

    attr_accessor :nonexistent_tenant_page
    attr_accessor :admission_criteria
    attr_accessor :default_tenant
    attr_accessor :current_tenant
    attr_accessor :reservation_system

    def initialize
      @reservation_system = ReservationSystem.new
      ActiveRecord::Base.connection_handler.tenants_source = begin
        @reservation_system.source
      end
    end

    def tenants_source_configurations(config)
      reservation_system.source_configurations(config)
      ActiveRecord::Base.connection_handler.tenants_source = begin
        reservation_system.source
      end
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

    private

      def remove_tenant_connection(name)
        ActiveRecord::Base.remove_connection(name)
      end

      def tenants_source
        reservation_system.source
      end

  end

end

