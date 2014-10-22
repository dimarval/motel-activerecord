require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/inflections'
require 'active_record'

module Motel
  module Manager

    mattr_accessor :default_tenant

    class << self

      def tenants_source_configurations(config)
        source_type = config[:source] || 'default'
        source_class = "Motel::Sources::#{source_type.to_s.camelize}".constantize

        source_instance = source_class.new(config)

        ::ActiveRecord::Base.connection_handler.tenants_source = source_instance
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
        ::ActiveRecord::Base.remove_connection(name)
        tenants_source.update_tenant(name, spec)
        tenant(name)
      end

      def delete_tenant(name)
        ::ActiveRecord::Base.remove_connection(name)
        tenants_source.delete_tenant(name)
        !tenant?(name)
      end

      def switch_tenant(name)
        Thread.current.thread_variable_set(:@current_tenant, name)
      end

      def active_tenants
        ::ActiveRecord::Base.connection_handler.active_tenants
      end

      def current_tenant
        ENV['TENANT'] ||
        Thread.current.thread_variable_get(:@current_tenant) ||
        default_tenant
      end

      def tenants_source
        ::ActiveRecord::Base.connection_handler.tenants_source
      end

      # Deprecated methods
      # -------------------------------------------------------------------------------------------
      def determines_tenant
        current_tenant
        warn "[DEPRECATION] `determines_tenant` is deprecated. Please use `current_tenant` instead."
      end

      def current_tenant=(name)
        switch_tenant(name)
        warn "[DEPRECATION] `current_tenant=` is deprecated. Please use `switch_tenant` instead."
      end

    end

  end
end

