require 'spec_helper'

describe Motel::ConnectionAdapters::ConnectionHandler do

  before(:each) do
    @handler = Motel::ConnectionAdapters::ConnectionHandler.new
    @handler.tenants_source.add_tenant('foo', FOO_SPEC)
    @handler.tenants_source.add_tenant('bar', BAR_SPEC)
  end

  describe '#establish_connection' do

    context 'specifying only the tenant name' do

      context 'existing tenant' do

        it 'returns an instance of ConnectionPool' do
          expect(
            @handler.establish_connection('foo')
          ).to be_an_instance_of ActiveRecord::ConnectionAdapters::ConnectionPool
        end

      end

      context 'nonexistent tenant' do

        it 'raise an error' do
          expect{
            @handler.establish_connection('baz')
          }.to raise_error Motel::NonexistentTenantError
        end

      end

    end

    context 'specifying tenant name and the spec' do

      it 'returns an instance if ConnectionPool' do
        resolver = Motel::ConnectionAdapters::ConnectionSpecification::Resolver.new
        spec = resolver.spec(BAZ_SPEC)
        expect(
          @handler.establish_connection('baz', spec)
        ).to be_an_instance_of ActiveRecord::ConnectionAdapters::ConnectionPool
      end

    end

  end

  describe '#retrieve_connection' do

    context 'existing tenant' do

      it 'initializes and returns a connection' do
        expect(@handler.retrieve_connection('foo')).to be_truthy
      end

      it 'returns a connection' do
        @pool = @handler.establish_connection('foo')
        expect(@handler.retrieve_connection('foo')).to eq @pool.connection
      end

    end

    context 'nonexistent tenant' do

      it 'raise an error' do
        expect{
          @handler.retrieve_connection('baz')
        }.to raise_error Motel::NonexistentTenantError
      end

    end

  end

  describe '#retrieve_connection_pool' do

    context 'existing tenant' do

      it 'initializes and returns a connection pool' do
        expect(@handler.retrieve_connection_pool('foo')).to be_truthy
      end

      it 'returns a connection pool' do
        @pool = @handler.establish_connection('foo')
        expect(@handler.retrieve_connection_pool('foo')).to eq @pool
      end

    end

    context 'nonexistent tenant' do

      it 'raise an error' do
        expect{
          @handler.retrieve_connection('baz')
        }.to raise_error Motel::NonexistentTenantError
      end

    end

  end

  describe '#connected?' do

    it 'returns true' do
      @handler.retrieve_connection('foo')
      expect(@handler.connected?('foo')).to be_truthy
    end

    it 'returns false' do
      expect(@handler.connected?('foo')).to be_falsey
    end

  end

  describe '#active_connections?' do

    it 'has not active connections' do
      expect(@handler.active_connections?).to be_falsey
    end

    it 'has active connections' do
      @handler.retrieve_connection('foo')
      expect(@handler.active_connections?).to be_truthy
    end

  end

  describe '#remove_connection' do

    it 'removes the connection' do
      @handler.retrieve_connection('foo')
      expect(@handler.active_connections?).to be_truthy

      @handler.remove_connection('foo')
      expect(@handler.active_connections?).to be_falsey
    end

  end

  describe '#active_tenants' do

    context 'no active tenants' do

      it 'returns empty array' do
        expect(@handler.active_tenants).to be_empty
      end

    end

    context 'are active tenants' do

      before(:each) do
        @handler.establish_connection('foo')
        @handler.establish_connection('bar')
      end


      it 'returns exactly two names' do
        expect(@handler.active_tenants.count).to eq 2
      end

      it 'returns the names' do
        expect(@handler.active_tenants).to include('foo', 'bar')
      end

    end

  end

  describe '#tenants_sources=' do

    it 'sets a tenats source for teh resolver' do
      @handler.tenants_source = Motel::Sources::Redis.new

      expect(@handler.tenants_source).to be_an_instance_of Motel::Sources::Redis
    end

  end

end

