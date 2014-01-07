require 'spec_helper'

describe Motel::Manager do

  before(:each) do
    @manager = Motel::Manager.new
    @tenants_source = @manager.tenants_source
    @tenants_source.add_tenant('foo', FOO_SPEC)
    @tenants_source.add_tenant('bar', BAR_SPEC)

    # FIXME hay discrepancia de fuentes de inquilinos al asignarsela por fuera
    # de la clase manager
    ActiveRecord::Base.connection_handler.tenants_source = @tenants_source
  end

  after(:each) do
    @manager.tenants_source = @tenants_source
    @tenants_source.tenants.keys.each do |tenant|
      @tenants_source.delete_tenant(tenant)
    end

    ActiveRecord::Base.connection_handler.active_tenants do |tenant|
      ActiveRecord::Base.connection_handler.remove_connection(tenant)
    end
  end

  describe '#tenants_source_configurations' do

    context 'redis source' do

      it 'tenants_source in connecion_handler of active record is an instance of redis' do
        @manager.tenants_source_configurations(:redis, {hots: 'localhost', port: 6379})
        expect(
          ActiveRecord::Base.connection_handler.tenants_source
        ).to be_an_instance_of Motel::Reservations::Sources::Redis
      end

    end

    context 'database source' do

      it 'tenants_source in connecion_handler of active record is an instance of database' do
        @manager.tenants_source_configurations(:database, {spec: TENANTS_SPEC, table_name: 'tenant'})
        expect(
          ActiveRecord::Base.connection_handler.tenants_source
        ).to be_an_instance_of Motel::Reservations::Sources::Database
      end

    end

  end

  describe '#tenants' do

    it 'returns tenant foo' do
      expect(@manager.tenants.key?('foo')).to be_true
    end

    it 'returns tenant bar' do
      expect(@manager.tenants.key?('bar')).to be_true
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
      expect(@manager.tenant?('foo')).to be_true
    end

    it 'returns true if tenant baz does exist' do
      resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(
        BAZ_SPEC, nil
      )
      handler = ActiveRecord::Base.connection_handler
      handler.establish_connection('baz', resolver.spec)
      expect(@manager.tenant?('baz')).to be_true
    end

    it 'returns false if tenant does not exist' do
      expect(@manager.tenant?('foobar')).to be_false
    end

  end

  describe '#add_tenant' do

    it 'adds new tenant' do
      @manager.add_tenant('baz', BAZ_SPEC)

      expect(@tenants_source.tenant?('baz')).to be_true
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
      expect(@manager.delete_tenant('foo')).to be_true
    end

    it 'deletes tenant' do
      @manager.delete_tenant('foo')
      expect(@tenants_source.tenant?('foo')).to be_false
    end

    it 'removes connection of tenant' do

      ActiveRecord::Base.connection_handler.establish_connection('foo')
      @manager.delete_tenant('foo')

      expect(ActiveRecord::Base.connection_handler.active_tenants).not_to include('foo')
    end

  end

  describe '#create_tenant_table' do

    it 'creates tenant table' do
      @manager.tenants_source = Motel::Reservations::ReservationSystem.source(
        :database, {source_spec: TENANTS_SPEC, table_name: 'tenant'}
      )
      expect(@manager.create_tenant_table).to be_true
      expect(@manager.tenants_source.add_tenant('foo', FOO_SPEC)).to be_true

      @manager.tenants_source.destroy_tenant_table
    end

  end

  describe '#destroy_tenant_table' do

    it 'returns true' do
      @manager.tenants_source = Motel::Reservations::ReservationSystem.source(
        :database, {source_spec: TENANTS_SPEC, table_name: 'tenant'}
      )

      @manager.tenants_source.create_tenant_table
      expect(@manager.destroy_tenant_table).to be_true
      expect{@manager.tenants_source.add_tenant('foo', FOO_SPEC)}.to raise_error
    end

  end

  describe '#active_tenants' do

    it 'returns active tenans' do
      ActiveRecord::Base.connection_handler.establish_connection('foo')
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

