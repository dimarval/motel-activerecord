require 'active_support/ordered_options'
require 'motel/manager'
require 'rails'

module Motel

  class Railtie < Rails::Railtie
    INIT_TO_DELETE = %w(active_record.initialize_database active_record.set_reloader_hooks)

    config.motel = ActiveSupport::OrderedOptions.new

    rake_tasks do
      namespace :db do
        task :load_config do
          Motel::Manager.tenants_source_configurations(
            Rails.application.config.motel.tenants_source_configurations
          )

          Motel::Manager.current_tenant = "ActiveRecord::Base"

          ActiveRecord::Tasks::DatabaseTasks.database_configuration = Motel::Manager.tenants
          ActiveRecord::Tasks::DatabaseTasks.env = Motel::Manager.determines_tenant
        end
      end
    end

    ActiveRecord::Railtie.initializers.delete_if do |i|
      INIT_TO_DELETE.include?(i.name)
    end

    initializer "motel.general_configuration" do
      motel_config = Rails.application.config.motel

      Motel::Manager.nonexistent_tenant_page = motel_config.nonexistent_tenant_page || 'public/404.html'
      Motel::Manager.admission_criteria = motel_config.admission_criteria
      Motel::Manager.default_tenant = motel_config.default_tenant
      Motel::Manager.current_tenant = motel_config.current_tenant
      Motel::Manager.tenants_source_configurations(motel_config.tenants_source_configurations)
    end

    initializer "motel.configure_middleware" do |app|
      if !Rails.application.config.motel.disable_middleware && (Rails.env != 'test')
        app.config.middleware.insert_before ActiveRecord::Migration::CheckPending, Lobby
      end
    end

    initializer "active_record.set_reloader_hooks" do |app|
      hook = app.config.reload_classes_only_on_change ? :to_prepare : :to_cleanup

      ActiveSupport.on_load(:active_record) do
        ActionDispatch::Reloader.send(hook) do
          if Motel::Manager.active_tenants.any?
            ActiveRecord::Base.clear_reloadable_connections!
            ActiveRecord::Base.clear_cache!
          end
        end
      end
    end

  end

end

