require 'rack'

module Motel

  class Lobby

    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      name = tenant_name(request)

      if name
        if ActiveRecord::Base.motel.tenant?(name)
          ActiveRecord::Base.motel.current_tenant = name
          @app.call(env)
        else
          path = ActiveRecord::Base.motel.nonexistent_tenant_page
          file = File.expand_path(path) if path
          body = (File.exists?(file.to_s)) ? File.read(file) : "No exising tenant"
          [404, {"Content-Type" => "text/html", "Content-Length" => body.size.to_s}, [body]]
        end
      else
        ActiveRecord::Base.motel.current_tenant = nil
        @app.call(env)
      end
    end

    private

      def tenant_name(request)
        admission_criteria = ActiveRecord::Base.motel.admission_criteria
        if admission_criteria
          name = request.host.match(admission_criteria)
          name[1] if name
        else
         request.host.split('.').first
        end
      end

  end

end

