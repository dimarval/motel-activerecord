require 'active_support/ordered_options'
require 'motel/manager'
require 'rails'

module Motel

  class Railtie < Rails::Railtie
    INIT_TO_DELETE = %w(active_record.initialize_database active_record.set_reloader_hooks)


    config.motel = ActiveSupport::OrderedOptions.new
    config.disable_motel_middleware = false

    rake_tasks do
      namespace :db do
        task :load_config do
          if defined? ActiveRecord::Tasks::DatabaseTasks
            ActiveRecord::Tasks::DatabaseTasks.env = ActiveRecord::Base.motel.determines_tenant
          end
        end
      end
    end

    ActiveRecord::Railtie.initializers.delete_if do |i|
      INIT_TO_DELETE.include?(i.name)
    end

    initializer "motel.general_configuration" do
      motel_config = Rails.application.config.motel

      ActiveRecord::Base.motel.nonexistent_tenant_page ||= begin
        motel_config.nonexistent_tenant_page || 'public/404.html'
      end

      ActiveRecord::Base.motel.default_tenant = motel_config.default_tenant
      ActiveRecord::Base.motel.current_tenant = motel_config.current_tenant
      ActiveRecord::Base.motel.admission_criteria = motel_config.admission_criteria

      if motel_config.tenants_source_configurations
        ActiveRecord::Base.motel.tenants_source_configurations(
          tenants_source_configurations
        )
      end
    end

    initializer "motel.configure_middleware" do |app|
      disable_middleware = Rails.application.config.disable_motel_middleware || false
      unless disable_middleware
        app.config.middleware.insert_before ActiveRecord::Migration::CheckPending, Lobby
      end
    end

    initializer "active_record.set_reloader_hooks" do |app|
      hook = app.config.reload_classes_only_on_change ? :to_prepare : :to_cleanup

      ActiveSupport.on_load(:active_record) do
        ActionDispatch::Reloader.send(hook) do
          if ActiveRecord::Base.motel.active_tenants.any?
            ActiveRecord::Base.clear_reloadable_connections!
            ActiveRecord::Base.clear_cache!
          end
        end
      end
    end

  end

end

