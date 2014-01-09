require 'spec_helper'

describe Motel::Sources::Database do

  before(:all) do
    @klass = Class.new(ActiveRecord::Base) { def self.name; 'klass'; end }

    resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(TENANTS_SPEC, nil)
    @handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new
    @handler.establish_connection(@klass, resolver.spec)

    @table_name = 'tenant'
    @tenants_source = Motel::Sources::Database.new(
      source_spec: TENANTS_SPEC, table_name: @table_name
    )

    @tenant_table_sql = <<-SQL
      CREATE TABLE #{@table_name}(
        `name`     VARCHAR PRIMARY KEY,
        `adapter`  VARCHAR,
        `socket`   VARCHAR,
        `port`     INTEGER,
        `pool`     INTEGER,
        `host`     VARCHAR,
        `username` VARCHAR,
        `password` VARCHAR,
        `database` VARCHAR
      )
    SQL
  end

  describe '#create_tenant_table' do

    it 'creates a tenant table on database' do
      @tenants_source.create_tenant_table

      expect(@handler.retrieve_connection(@klass).table_exists?(@table_name)).to be_true
      expect(@handler.retrieve_connection(@klass).column_exists?(@table_name, :name, :string)).to be_true
      expect(@handler.retrieve_connection(@klass).column_exists?(@table_name, :adapter, :string)).to be_true
      expect(@handler.retrieve_connection(@klass).column_exists?(@table_name, :database, :string)).to be_true

      @handler.retrieve_connection_pool(@klass).with_connection do |conn|
        if conn.table_exists?(@table_name)
          conn.drop_table(@table_name)
        end
      end
    end

  end

  describe '#destroy_tenant_table' do

    it 'destroy tenant table in the database' do
      @handler.retrieve_connection_pool(@klass).with_connection do |conn|
        conn.execute(@tenant_table_sql)
      end

      @tenants_source.destroy_tenant_table
      expect(@handler.retrieve_connection(@klass).table_exists?(@table_name)).to be_false
    end

  end

  context 'there is a tenant table' do

    before(:all) do
      @handler.retrieve_connection_pool(@klass).with_connection do |conn|
        conn.execute(@tenant_table_sql)
      end
    end

    before (:each) do
      @foo_tenant_sql = <<-SQL
        INSERT INTO #{@table_name}(`name`, `adapter`, `database`)
        VALUES ("foo", "#{FOO_SPEC['adapter']}", "#{FOO_SPEC['database']}")
      SQL

      @bar_tenant_sql = <<-SQL
        INSERT INTO #{@table_name}(`name`, `adapter`, `database`)
        VALUES ("bar", "#{BAR_SPEC['adapter']}", "#{BAR_SPEC['database']}")
      SQL

      @handler.retrieve_connection_pool(@klass).with_connection do |conn|
        conn.execute(@foo_tenant_sql)
        conn.execute(@bar_tenant_sql)
      end
    end

    after(:each) do
      @handler.retrieve_connection_pool(@klass).with_connection do |conn|
        conn.execute("DELETE FROM #{@table_name}")
      end
    end

    after(:all) do
      @handler.retrieve_connection_pool(@klass).with_connection do |conn|
        conn.execute("DROP TABLE #{@table_name}")
      end
    end

    describe '#tenants' do

      it 'there are only two tenants' do
        expect(@tenants_source.tenants.count).to eq 2
      end

      it 'exist foo key' do
        expect(@tenants_source.tenants.key?('foo')).to be_true
      end

      it 'tenant foo has a correct spec' do
        expect(@tenants_source.tenants['foo']['adapter']).to eq FOO_SPEC['adapter']
        expect(@tenants_source.tenants['foo']['database']).to eq FOO_SPEC['database']
      end

      it 'exist bar key' do
        expect(@tenants_source.tenants.key?('bar')).to be_true
      end

      it 'tenant bar has a correct spec' do
        expect(@tenants_source.tenants['bar']['adapter']).to eq BAR_SPEC['adapter']
        expect(@tenants_source.tenants['bar']['database']).to eq BAR_SPEC['database']
      end

    end

    describe '#tenant' do

      context 'existing tenant' do

        it 'tenant foo has a correct spec' do
          expect(@tenants_source.tenant('foo')['adapter']).to eq FOO_SPEC['adapter']
          expect(@tenants_source.tenant('foo')['database']).to eq FOO_SPEC['database']
        end

      end

      context 'nonexistent tenant' do

        it 'returns null' do
          expect(@tenants_source.tenant('baz')).to be_nil
        end

      end

    end

    describe '#tenant?' do

      it 'returns true if tenant does exist' do
        expect(@tenants_source.tenant?('foo')).to be_true
      end

      it 'returns false if tenant does not exist' do
        expect(@tenants_source.tenant?('baz')).to be_false
      end

    end

    describe '#add_tenant' do

      context 'existing tenant' do

        it 'raise an error' do
          expect{
            @tenants_source.add_tenant('foo', FOO_SPEC)
          }.to raise_error Motel::ExistingTenantError
        end

      end

      context 'nonexistent tenant' do

        context 'spec has keys as strings' do

          it 'add new tenant to database' do
            @tenants_source.add_tenant(
              'baz', {'adapter'  => BAZ_SPEC['adapter'], 'database' => BAZ_SPEC['database']}
            )

            result = @handler.retrieve_connection_pool(@klass).with_connection do |conn|
              conn.select_all("SELECT * FROM #{@table_name} WHERE `name` = 'baz'")
            end

            expect(result.first['adapter']).to eq BAZ_SPEC['adapter']
            expect(result.first['database']).to eq BAZ_SPEC['database']
          end

        end

        context 'spec has keys as symbols' do

          it 'add new tenant to database' do
            @tenants_source.add_tenant(
              'baz', {adapter:  BAZ_SPEC['adapter'] , database: BAZ_SPEC['database']}
            )

            result = @handler.retrieve_connection_pool(@klass).with_connection do |conn|
              conn.select_all("SELECT * FROM #{@table_name} WHERE `name` = 'baz'")
            end

            expect(result.first['adapter']).to eq BAZ_SPEC['adapter']
            expect(result.first['database']).to eq BAZ_SPEC['database']
          end

        end

      end

    end

    describe '#update_tenant' do

      context 'existing tenant' do

        context 'full update' do

          it 'update tenant in the database' do
            @tenants_source.update_tenant(
              'foo', {adapter: 'mysql2', database: 'foo'}
            )

            result = @handler.retrieve_connection_pool(@klass).with_connection do |conn|
              conn.select_all("SELECT * FROM #{@table_name} WHERE `name` = 'foo'")
            end

            expect(result.first['adapter']).to eq 'mysql2'
            expect(result.first['database']).to eq 'foo'
          end

        end

        context 'partial update' do

          it 'update tenant in the database' do
            @tenants_source.update_tenant(
              'foo', {adapter: 'mysql2'}
            )

            result = @handler.retrieve_connection_pool(@klass).with_connection do |conn|
              conn.select_all("SELECT * FROM #{@table_name} WHERE `name` = 'foo'")
            end

            expect(result.first['adapter']).to eq 'mysql2'
            expect(result.first['database']).to eq FOO_SPEC['database']
          end

        end

      end

      context 'nonexistent tenant' do

        it 'raise an error' do
          expect{
            @tenants_source.update_tenant('baz', {})
          }.to raise_error Motel::NonexistentTenantError
        end

      end

    end

    describe '#delete_tenant' do

      it 'remove tenant from redis server' do
        @tenants_source.delete_tenant('foo')

        result = @handler.retrieve_connection_pool(@klass).with_connection do |conn|
          conn.select_all("SELECT * FROM #{@table_name} WHERE `name` = 'foo'")
        end

        expect(result.count).to eq 0
      end

    end

  end

end

