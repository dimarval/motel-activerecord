require 'spec_helper'

describe Motel::Manager do

  before(:all) do
    ::ActiveRecord::Base.connection_handler = begin
      Motel::ConnectionAdapters::ConnectionHandler.new
    end
    @manager = Motel::Manager
  end

  before(:each) do
    ::ActiveRecord::Base.connection_handler.tenants_source = begin
      Motel::Sources::Default.new
    end
    @tenants_source = ::ActiveRecord::Base.connection_handler.tenants_source
    @tenants_source.add_tenant('foo', FOO_SPEC)
    @tenants_source.add_tenant('bar', BAR_SPEC)
  end

  after(:each) do
    ENV['TENANT'] = nil
    @manager.current_tenant = nil
    @manager.default_tenant = nil

    # Remove all connections tenant
    ::ActiveRecord::Base.connection_handler.active_tenants do |tenant|
      ::ActiveRecord::Base.connection_handler.remove_connection(tenant)
    end
  end

  describe '#tenants_source_configurations' do

    context 'redis source' do

      before(:each) do
        @manager.tenants_source_configurations({
          source:              :redis,
          host:                'localhost',
          port:                6380,
          password:            'none',
          path:                '/tmp/redis.sock',
          prefix_tenant_alias: 'test-tenant'
        })
      end

      it 'places a redis instance on the source' do
        expect(@manager.tenants_source).to be_an_instance_of Motel::Sources::Redis
      end

      it 'source attributes has a correct values' do
        expect(@manager.tenants_source.host).to                eq 'localhost'
        expect(@manager.tenants_source.port).to                eq 6380
        expect(@manager.tenants_source.password).to            eq 'none'
        expect(@manager.tenants_source.path).to                eq '/tmp/redis.sock'
        expect(@manager.tenants_source.prefix_tenant_alias).to eq 'test-tenant'
      end

    end

    context 'database source' do

      before(:each) do
        @manager.tenants_source_configurations({
          source:      :database,
          source_spec: TENANTS_SPEC,
          table_name:  'tenant'
        })
      end

      it 'places a database instance on the source' do
        expect(@manager.tenants_source).to be_an_instance_of Motel::Sources::Database
      end

      it 'source attributes has a correct values' do
        expect(@manager.tenants_source.source_spec).to eq TENANTS_SPEC
        expect(@manager.tenants_source.table_name).to  eq 'tenant'
      end

    end

    context 'default source' do

      before(:each) do
        @manager.tenants_source_configurations({source: :default})
      end

      it 'places a default instance on the source' do
        expect(@manager.tenants_source).to be_an_instance_of Motel::Sources::Default
      end

    end

  end

  describe '#tenants' do

    it 'returns tenant foo' do
      expect(@manager.tenants.key?('foo')).to be_truthy
    end

    it 'returns tenant bar' do
      expect(@manager.tenants.key?('bar')).to be_truthy
    end

  end

  describe '#tenant' do

    it 'returns tenant foo spec' do
      expect(@manager.tenant('foo')['adapter']).to eq FOO_SPEC['adapter']
      expect(@manager.tenant('foo')['database']).to eq FOO_SPEC['database']
    end

  end

  describe '#tenant?' do

    it 'returns true if tenant foo does exist' do
      expect(@manager.tenant?('foo')).to be_truthy
    end

    it 'returns true if tenant baz does exist' do
      resolver = Motel::ConnectionAdapters::ConnectionSpecification::Resolver.new
      spec = resolver.spec(BAZ_SPEC)
      handler = ::ActiveRecord::Base.connection_handler
      handler.establish_connection('baz', spec)
      expect(@manager.tenant?('baz')).to be_truthy
    end

    it 'returns false if tenant does not exist' do
      expect(@manager.tenant?('foobar')).to be_falsey
    end

  end

  describe '#add_tenant' do

    it 'adds new tenant' do
      @manager.add_tenant('baz', BAZ_SPEC)

      expect(@tenants_source.tenant?('baz')).to be_truthy
    end

  end

  describe '#update_tenant' do

    it 'updates tenant' do
      @manager.update_tenant('foo', {adapter: 'mysql2', database: 'foo'})

      expect(@tenants_source.tenant('foo')['adapter']).to  eq 'mysql2'
      expect(@tenants_source.tenant('foo')['database']).to eq 'foo'
    end

    it 'returns the spec unpdated' do
      spec_updated = @manager.update_tenant('foo', {adapter: 'mysql2', database: 'foo'})


      expect(spec_updated['adapter']).to  eq 'mysql2'
      expect(spec_updated['database']).to eq 'foo'
    end

  end

  describe '#delete_tenant' do

    it 'returns true' do
      expect(@manager.delete_tenant('foo')).to be_truthy
    end

    it 'deletes tenant' do
      @manager.delete_tenant('foo')
      expect(@tenants_source.tenant?('foo')).to be_falsey
    end

    it 'removes connection of tenant' do

      ::ActiveRecord::Base.connection_handler.establish_connection('foo')
      @manager.delete_tenant('foo')

      expect(::ActiveRecord::Base.connection_handler.active_tenants).not_to include('foo')
    end

  end

  describe '#active_tenants' do

    it 'returns active tenans' do
      ::ActiveRecord::Base.connection_handler.establish_connection('foo')
      expect(@manager.active_tenants).to include('foo')
    end

  end

  describe '#determines_tenant' do

    context 'tenant environment variable, current tenant and default tenant are set' do

      it 'returns tenant enviroment variable' do
        ENV['TENANT'] = 'foo'
        @manager.current_tenant = 'bar'
        @manager.default_tenant = 'baz'

        expect(@manager.determines_tenant).to eq ENV['TENANT']
      end

    end

    context 'only current tenant and default tenant are set' do

      it 'returns tenant enviroment variable' do
        ENV['TENANT'] = nil
        @manager.current_tenant = 'bar'
        @manager.default_tenant = 'baz'

        expect(@manager.determines_tenant).to eq @manager.current_tenant
      end

    end

    context 'only default tenant is set' do

      it 'returns tenant enviroment variable' do
        ENV['TENANT'] = nil
        @manager.current_tenant = nil
        @manager.default_tenant = 'baz'

        expect(@manager.determines_tenant).to eq @manager.default_tenant
      end

    end

  end

end

