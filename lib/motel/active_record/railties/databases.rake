require 'active_record'

db_namespace = namespace :db do

  Rake::Task['db:create:all'].clear
  namespace :create do
    task :all => :load_config do
      Motel::Manager.tenants.each do |tenant_name, config|
        Motel::Manager.switch_tenant(tenant_name)
        ActiveRecord::Tasks::DatabaseTasks.create config
      end
    end
  end

  Rake::Task['db:drop:all'].clear
  namespace :drop do
    task :all => :load_config do
      Motel::Manager.tenants.each do |tenant_name, config|
        Motel::Manager.switch_tenant(tenant_name)
        ActiveRecord::Tasks::DatabaseTasks.drop config
      end
    end
  end

  if Rake::Task.task_defined?('db:purge:all')
    Rake::Task['db:purge:all'].clear
    namespace :purge do
      task :all => :load_config do
        Motel::Manager.tenants.each do |tenant_name, config|
          Motel::Manager.switch_tenant(tenant_name)
          ActiveRecord::Tasks::DatabaseTasks.purge config
        end
      end
    end
  end

end

