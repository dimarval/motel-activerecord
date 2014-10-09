require 'uri'
require 'active_record'
require 'active_support/core_ext/hash/keys'

module Motel
  module ConnectionAdapters
    module ConnectionSpecification
      class Resolver

        attr_accessor :configurations

        def initialize(configurations = nil)
          @configurations = configurations || {}
        end

        def spec(config)
          spec = resolve(config).symbolize_keys

          raise(::ActiveRecord::AdapterNotSpecified, "database configuration does not specify adapter") unless spec.key?(:adapter)

          path_to_adapter = "active_record/connection_adapters/#{spec[:adapter]}_adapter"
          begin
            require path_to_adapter
          rescue Gem::LoadError => e
            raise Gem::LoadError, "Specified '#{spec[:adapter]}' for database adapter, but the gem is not loaded. Add `gem '#{e.name}'` to your Gemfile (and ensure its version is at the minimum required by ActiveRecord)."
          rescue LoadError => e
            raise LoadError, "Could not load '#{path_to_adapter}'. Make sure that the adapter in config/database.yml is valid. If you use an adapter other than 'mysql', 'mysql2', 'postgresql' or 'sqlite3' add the necessary adapter gem to the Gemfile.", e.backtrace
          end

          adapter_method = "#{spec[:adapter]}_connection"
          ::ActiveRecord::ConnectionAdapters::ConnectionSpecification.new(spec, adapter_method)
        end

        private

          def resolve(config)
            case config
            when nil
              raise ::ActiveRecord::AdapterNotSpecified
            when String, Symbol
              resolve_string_connection config.to_s
            when Hash
              resolve_hash_connection config
            end
          end

          def resolve_hash_connection(spec)
            if url = spec.delete("url")
              connection_hash = resolve_string_connection(url)
              spec.merge!(connection_hash)
            end
            spec
          end

          def resolve_string_connection(spec)
            hash = configurations.fetch(spec) do |k|
              connection_url_to_hash(k)
            end

            resolve_hash_connection hash
          end

          def connection_url_to_hash(url)
            config = URI.parse url
            adapter = config.scheme
            adapter = "postgresql" if adapter == "postgres"
            spec = { :adapter => adapter,
                     :username => config.user,
                     :password => config.password,
                     :port => config.port,
                     :database => config.path.sub(%r{^/},""),
                     :host => config.host }

            spec.reject!{ |_,value| value.blank? }

            uri_parser = URI::Parser.new

            spec.map { |key,value| spec[key] = uri_parser.unescape(value) if value.is_a?(String) }

            if config.query
              options = Hash[config.query.split("&").map{ |pair| pair.split("=") }].symbolize_keys

              spec.merge!(options)
            end

            spec
          end

      end
    end
  end
end
