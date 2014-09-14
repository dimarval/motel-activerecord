require 'spec_helper'

describe ActiveRecord::Base do

  before(:all) do
    Motel::Manager.tenants_source_configurations({source: :default})
    Motel::Manager.add_tenant('foo', FOO_SPEC)
    Motel::Manager.add_tenant('bar', BAR_SPEC)
  end

  after(:all) do
    Motel::Manager.delete_tenant('foo')
    Motel::Manager.delete_tenant('bar')
  end

  after(:each) do
    ActiveRecord::Base.connection_handler.active_tenants do |tenant|
      ActiveRecord::Base.connection_handler.remove_connection(tenant)
    end
    Motel::Manager.current_tenant = nil
  end

  describe '.establish_connection' do

    context 'setting the current tenant name' do

      before(:each) do
        Motel::Manager.current_tenant = 'foo'
      end

      it 'establishes a connection keyed by tenant name' do
        ActiveRecord::Base.establish_connection(FOO_SPEC)

        expect(ActiveRecord::Base.connection_handler.active_tenants).to include('foo')
      end

    end

    context 'without setting the current tenant name' do

      it 'establishes a connection keyed by class name' do
        ActiveRecord::Base.establish_connection(BAZ_SPEC)

        expect(ActiveRecord::Base.connection_handler.active_tenants).to include('ActiveRecord::Base')
      end

    end

  end

  describe '.connection_pool' do

    context 'current tenant established' do

      it 'returns a connection pool of current tenant' do
        Motel::Manager.current_tenant = 'foo'
        pool = ActiveRecord::Base.connection_handler.establish_connection('foo')

        expect(ActiveRecord::Base.connection_pool).to eq pool
      end

    end

    context 'current tenant not established' do

      it 'rises an error' do
        Motel::Manager.current_tenant = nil
        expect{ActiveRecord::Base.connection_pool}.to raise_error Motel::NoCurrentTenantError
      end

    end

  end

  describe '.retrieve_connection' do

    context 'current tenant established' do

      it 'returns a connection of current tenant' do
        Motel::Manager.current_tenant = 'foo'
        pool = ActiveRecord::Base.connection_handler.establish_connection('foo')

        expect(ActiveRecord::Base.retrieve_connection).to eq pool.connection
      end

    end

    context 'current tenant not established' do

      it 'rises an error' do
        Motel::Manager.current_tenant = nil
        expect{ActiveRecord::Base.retrieve_connection}.to raise_error Motel::NoCurrentTenantError
      end

    end

  end

  describe '.connected?' do

    before(:each) do
      ActiveRecord::Base.connection_handler.retrieve_connection('foo')
    end

    context 'current tenant established' do

      it 'returns true' do
        Motel::Manager.current_tenant = 'foo'
        expect(ActiveRecord::Base.connected?).to be_truthy
      end

      it 'returns false' do
        Motel::Manager.current_tenant = 'bar'
        expect(ActiveRecord::Base.connected?).to be_falsey
      end

    end

    context 'current tenant not established' do

      it 'rises an error' do
        Motel::Manager.current_tenant = nil
        expect{ActiveRecord::Base.connected?}.to raise_error Motel::NoCurrentTenantError
      end

    end

  end

  describe '.remove_connection' do

    context 'current tenant established' do

      it 'removes connection' do
        ActiveRecord::Base.connection_handler.establish_connection('foo')
        Motel::Manager.current_tenant = 'foo'
        ActiveRecord::Base.remove_connection
        expect(ActiveRecord::Base.connection_handler.active_tenants).not_to include('foo')
      end

    end

    context 'current tenant not established' do

      it 'rises an error' do
        Motel::Manager.current_tenant = nil
        expect{ActiveRecord::Base.remove_connection}.to raise_error Motel::NoCurrentTenantError
      end

    end

  end

  describe '.arel_engine' do

    it 'returns a ActiveRecord::Base class' do
      expect(ActiveRecord::Base.arel_engine).to eq ActiveRecord::Base
    end

  end

  describe '.current_tenant' do

    context 'tenant enviroment variable or current tenant or default tenant are set' do

      it 'returns the current tenant' do
        Motel::Manager.current_tenant = 'foo'

        expect(ActiveRecord::Base.current_tenant).to eq 'foo'
      end

    end

    context 'no tenant has been established' do

      it 'rises an error' do
        Motel::Manager.current_tenant = nil

        expect{ActiveRecord::Base.current_tenant}.to raise_error Motel::NoCurrentTenantError
      end

    end

  end

end

