require 'active_support/ordered_options'
require 'motel/manager'
require 'active_record'
require 'rails'
require 'active_model/railtie'

module Motel

  class Railtie < Rails::Railtie
    INIT_TO_DELETE = %w(active_record.initialize_database active_record.set_reloader_hooks)

    config.motel = ActiveSupport::OrderedOptions.new

    config.action_dispatch.rescue_responses.merge!(
      'Motel::NoCurrentTenantError' => :not_found,
      'Motel::NonexistentTenantError' => :not_found
    )

    rake_tasks do
      require "active_record/base"

      namespace :db do
        task :load_config do
          Motel::Manager.tenants_source_configurations(
            Rails.application.config.motel.tenants_source_configurations
          )

          ::ActiveRecord::Tasks::DatabaseTasks.database_configuration = Motel::Manager.tenants
          ::ActiveRecord::Base.configurations = ::ActiveRecord::Tasks::DatabaseTasks.database_configuration
          ::ActiveRecord::Tasks::DatabaseTasks.env = Motel::Manager.current_tenant
        end
      end

      load "motel/active_record/railties/databases.rake"
    end

    ::ActiveRecord::Railtie.initializers.delete_if do |i|
      INIT_TO_DELETE.include?(i.name)
    end

    initializer "motel.general_configuration" do
      motel_config = Rails.application.config.motel

      Motel::Manager.default_tenant = motel_config.default_tenant
      Motel::Manager.tenants_source_configurations(motel_config.tenants_source_configurations)
    end

    initializer "active_record.set_reloader_hooks" do |app|
      hook = app.config.reload_classes_only_on_change ? :to_prepare : :to_cleanup

      ActiveSupport.on_load(:active_record) do
        ActionDispatch::Reloader.send(hook) do
          ::ActiveRecord::Base.clear_reloadable_connections!
          # Clear cache of the current tenant with an active connection
          if Motel::Manager.active_tenants.include?(Motel::Manager.current_tenant)
            ::ActiveRecord::Base.clear_cache!
          end
        end
      end
    end

  end

end

