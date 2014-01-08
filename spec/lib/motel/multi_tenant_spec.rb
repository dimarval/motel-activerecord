require 'spec_helper'

describe ActiveRecord::Base do

  before(:all) do
    ActiveRecord::Base.motel.add_tenant('foo', FOO_SPEC)
    ActiveRecord::Base.motel.add_tenant('bar', BAR_SPEC)
  end

  after(:all) do
    ActiveRecord::Base.motel.delete_tenant('foo')
    ActiveRecord::Base.motel.delete_tenant('bar')
  end

  after(:each) do
    ActiveRecord::Base.connection_handler.active_tenants do |tenant|
      ActiveRecord::Base.connection_handler.remove_connection(tenant)
    end
    ActiveRecord::Base.motel.current_tenant = nil
  end

  describe '.establish_connection' do

    it 'establish a connection' do
      ActiveRecord::Base.establish_connection('foo')
      expect(ActiveRecord::Base.connection_handler.active_tenants).to include('foo')
    end

  end

  describe '.connection_pool' do

    context 'current tenant established' do

      it 'returns a connection pool of current tenant' do
        ActiveRecord::Base.motel.current_tenant = 'foo'
        pool = ActiveRecord::Base.connection_handler.establish_connection('foo')

        expect(ActiveRecord::Base.connection_pool).to eq pool
      end

    end

    context 'current tenant not established' do

      it 'rises an error' do
        ActiveRecord::Base.motel.current_tenant = nil
        expect{ActiveRecord::Base.connection_pool}.to raise_error Motel::NoCurrentTenantError
      end

    end

  end

  describe '.retrieve_connection' do

    context 'current tenant established' do

      it 'returns a connection of current tenant' do
        ActiveRecord::Base.motel.current_tenant = 'foo'
        pool = ActiveRecord::Base.connection_handler.establish_connection('foo')

        expect(ActiveRecord::Base.retrieve_connection).to eq pool.connection
      end

    end

    context 'current tenant not established' do

      it 'rises an error' do
        ActiveRecord::Base.motel.current_tenant = nil
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
        ActiveRecord::Base.motel.current_tenant = 'foo'
        expect(ActiveRecord::Base.connected?).to be_true
      end

      it 'returns false' do
        ActiveRecord::Base.motel.current_tenant = 'bar'
        expect(ActiveRecord::Base.connected?).to be_false
      end

    end

    context 'current tenant not established' do

      it 'rises an error' do
        ActiveRecord::Base.motel.current_tenant = nil
        expect{ActiveRecord::Base.connected?}.to raise_error Motel::NoCurrentTenantError
      end

    end

  end

  describe '.remove_connection' do

    context 'current tenant established' do

      it 'removes connection' do
        ActiveRecord::Base.connection_handler.establish_connection('foo')
        ActiveRecord::Base.motel.current_tenant = 'foo'
        ActiveRecord::Base.remove_connection
        expect(ActiveRecord::Base.connection_handler.active_tenants).not_to include('foo')
      end

    end

    context 'current tenant not established' do

      it 'rises an error' do
        ActiveRecord::Base.motel.current_tenant = nil
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
        ActiveRecord::Base.motel.current_tenant = 'foo'

        expect(ActiveRecord::Base.current_tenant).to eq 'foo'
      end

    end

    context 'no tenant has been established' do

      it 'rises an error' do
        ActiveRecord::Base.motel.current_tenant = nil

        expect{ActiveRecord::Base.current_tenant}.to raise_error Motel::NoCurrentTenantError
      end

    end

  end

end

