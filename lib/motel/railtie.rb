require 'rails'
require 'motel/manager'

module Motel

  class Railtie < Rails::Railtie
    config.motel = Manager.new

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
      unless ActiveRecord::Base.motel.nonexistent_tenant_page
        ActiveRecord::Base.motel.nonexistent_tenant_page = 'public/404.html'
      end
    end

    initializer "motel.configure_middleware" do |app|
      unless ActiveRecord::Base.motel.disable_middleware
        app.config.middleware.insert_before ActiveRecord::Migration::CheckPending, Lobby
      end
    end

    ActiveRecord::Railtie.initializers.delete_if do |i|
      i.name == "active_record.initialize_database"
    end

  end

end

