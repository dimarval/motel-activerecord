require 'redis'

module Motel
  module Sources

    class Redis

      attr_accessor :host, :port, :password, :path, :prefix_tenant_alias

      def initialize(config = {})
        @host                = config[:host]
        @port                = config[:port]
        @password            = config[:password]
        @path                = config[:path]
        @prefix_tenant_alias = (config[:prefix_tenant_alias] || 'tenant:')
      end

      def tenants
        redis.keys.inject({}) do |hash, tenant_als|
          if tenant_als.match("^#{prefix_tenant_alias}")
            hash[tenant_name(tenant_als)] = tenant(tenant_name(tenant_als))
          end
          hash
        end
      end

      def tenant(name)
        spec = redis.hgetall(tenant_alias(name))
        spec if spec.any?
      end

      def tenant?(name)
        !tenant(name).nil?
      end

      def add_tenant(name, spec)
        raise ExistingTenantError if tenant?(name)

        spec.each do |field, value|
          redis.hset(tenant_alias(name), field, value)
        end
      end

      def update_tenant(name, spec)
        raise NonexistentTenantError unless tenant?(name)

        spec.each do |field, value|
          redis.hset(tenant_alias(name), field, value)
        end
      end

      def delete_tenant(name)
        if tenant?(name)
          fields = redis.hkeys tenant_alias(name)
          redis.hdel(tenant_alias(name), [*fields])
        end
      end

      private

        def redis
          @redis ||= begin
            ::Redis.new(host: host, port: port, password: password, path: path)
          end
        end

        def tenant_alias(name)
          "#{prefix_tenant_alias}#{name}"
        end

        def tenant_name(tenant_alias)
          name = tenant_alias.match("#{prefix_tenant_alias}(.*)")
          name[1] if name
        end

    end

  end
end

