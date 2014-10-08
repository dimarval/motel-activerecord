require 'active_record/query_cache'

module ActiveRecord
  class QueryCache

    class << self

      # Enable the query cache within the block if Active Record is configured.
      # If it's not, it will execute the given block.
      def cache(&block)
        if (Motel::Manager.default_tenant || Motel::Manager.current_tenant) &&
            ActiveRecord::Base.connected?
          connection.cache(&block)
        else
          yield
        end
      end

      # Disable the query cache within the block if Active Record is configured.
      # If it's not, it will execute the given block.
      def uncached(&block)
        if (Motel::Manager.default_tenant || Motel::Manager.current_tenant) &&
            ActiveRecord::Base.connected?
          connection.uncached(&block)
        else
          yield
        end
      end

    end

    def call(env)
      if Motel::Manager.default_tenant || Motel::Manager.current_tenant
        connection    = ActiveRecord::Base.connection
        enabled       = connection.query_cache_enabled
        connection_id = ActiveRecord::Base.connection_id
        connection.enable_query_cache!

        response = @app.call(env)
        response[2] = Rack::BodyProxy.new(response[2]) do
          restore_query_cache_settings(connection_id, enabled)
        end

        response
      else
        @app.call(env)
      end
    rescue Exception => e
      restore_query_cache_settings(connection_id, enabled)
      raise e
    end

  end

end

