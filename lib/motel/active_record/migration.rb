require 'active_record'

module ActiveRecord

  class Migration

    class CheckPending

      def call(env)
        return @app.call(env) unless determines_tenant

        if connection.supports_migrations?
          mtime = ActiveRecord::Migrator.last_migration.mtime.to_i
          if @last_check < mtime
            ActiveRecord::Migration.check_pending!(connection)
            @last_check = mtime
          end
        end

        @app.call(env)
      end

      private

        def connection
          ActiveRecord::Base.connection
        end

        def determines_tenant
          Motel::Manager.current_tenant || Motel::Manager.default_tenant
        end

    end

  end

end

