require 'active_record'

module Motel
  module Sources

    class Database

      attr_accessor :source_spec, :table_name

      def initialize(config = {})
        @source_spec = config[:source_spec]
        @table_name  = config[:table_name]
      end

      def tenants
        query_result.inject({}) do |hash, tenant|
          name = tenant.delete('name')

          tenant.each do |field, value|
            if table[field].respond_to? :column
              tenant[field] = table[field].column.type_cast(value)
            end
          end

          hash[name] = tenant
          hash
        end
      end

      def tenant(name)
        tenants[name]
      end

      def tenant?(name)
        tenants.key?(name)
      end

      def add_tenant(name, spec)
        raise ExistingTenantError if tenant?(name)

        spec = spec.merge(:name => name.to_s)
        spec.delete_if{ |c,v| v.nil? }

        sql = <<-SQL
          INSERT INTO #{table_name} (#{spec.keys.map{|c| "\`#{c}\`"}.join(',')})
          VALUES (#{spec.values.map(&:inspect).join(',')})
        SQL

        connection_pool.with_connection { |conn| conn.execute(sql) }
      end

      def update_tenant(name, spec)
        raise NonexistentTenantError unless tenant?(name)

        spec = spec.merge(:name => name.to_s)
        spec.delete_if{ |c,v| v.nil? }

        sql = <<-SQL
          UPDATE #{table_name}
          SET #{spec.map{|c, v| "\`#{c}\` = \"#{v}\""}.join(',')}
          WHERE name = "#{name}"
        SQL

        connection_pool.with_connection { |conn| conn.execute(sql) }
      end

      def delete_tenant(name)
        if tenant?(name)
          sql = <<-SQL
            DELETE FROM #{table_name} WHERE name = "#{name}"
          SQL

          connection_pool.with_connection { |conn| conn.execute(sql) }
        end
      end

      def connection
        connection_pool.connection
      end

      private

        def table
          @table ||= Arel::Table.new(table_name, self)
        end

        def query
          @query ||= table.project('*')
        end

        def query_result
          connection_pool.with_connection do |conn|
            conn.select_all(query.to_sql)
          end
        end

        def spec
          @spec ||= begin
            resolver = Motel::ConnectionAdapters::ConnectionSpecification::Resolver.new
            resolver.spec(source_spec)
          end
        end

        def connection_handler
          @connection_handler ||= begin
            handler = Motel::ConnectionAdapters::ConnectionHandler.new
            handler.establish_connection self.class, spec
            handler
          end
        end

        def connection_pool
          connection_handler.retrieve_connection_pool self.class
        end

    end

  end
end

