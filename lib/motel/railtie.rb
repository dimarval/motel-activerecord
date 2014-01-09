require 'active_support/ordered_options'
require 'motel/manager'
require 'rails'

module Motel

  class Railtie < Rails::Railtie
    config.motel = ActiveSupport::OrderedOptions.new
    config.disable_motel_middleware = false

    rake_tasks do
      namespace :db do
        task :load_config do
          if defined? ActiveRecord::Tasks::DatabaseTasks
            ActiveRecord::Tasks::DatabaseTasks.env = ENV['TENANT'] || ActiveRecord::Base.motel.default_tenant
          end
        end
      end
    end

    initializer "motel.general_configuration" do
      ActiveRecord::Base.motel.nonexistent_tenant_page ||= begin
        config.motel.nonexistent_tenant_page || 'public/404.html'
      end
      ActiveRecord::Base.motel.default_tenant = Rails.application.config.motel.default_tenant
      ActiveRecord::Base.motel.current_tenant = Rails.application.config.motel.current_tenant
      ActiveRecord::Base.motel.admission_criteria = Rails.application.config.motel.admission_criteria

      source_configurations = Rails.application.config.motel.tenants_source_configurations
      if source_configurations
        ActiveRecord::Base.motel.tenants_source_configurations(source_configurations)
      end
    end

    initializer "motel.configure_middleware" do |app|
      disable_middleware = Rails.application.config.disable_motel_middleware || false
      unless disable_middleware
        app.config.middleware.insert_before ActiveRecord::Migration::CheckPending, Lobby
      end
    end

    ActiveRecord::Railtie.initializers.delete_if do |i|
      i.name == "active_record.initialize_database"
    end

  end

end

