require 'rack'

module Motel

  class Lobby

    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      name = tenant_name(request)

      if name && Motel::Manager.tenant?(name)
        Motel::Manager.current_tenant = name
      else
        Motel::Manager.current_tenant = nil
      end

      @app.call(env)
    end

    private

      def tenant_name(request)
        if Motel::Manager.admission_criteria
          regex = Regexp.new(Motel::Manager.admission_criteria)
          name = request.path.match(regex)
          name[1] if name
        else
         request.host.split('.').first
        end
      end

  end

end

