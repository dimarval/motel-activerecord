require 'spec_helper'

describe Motel::ConnectionAdapters::ConnectionHandler do

  before(:all) do
    @tenants_source = Motel::Reservations::Sources::Default.new
    @tenants_source.add_tenant('foo', FOO_SPEC)
    @tenants_source.add_tenant('bar', BAR_SPEC)
  end

  after(:all) do
    @tenants_source.delete_tenant('foo')
    @tenants_source.delete_tenant('bar')
  end

  before(:each) do
    @handler = Motel::ConnectionAdapters::ConnectionHandler.new(@tenants_source)
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
        resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(
          BAZ_SPEC, nil
        )
        expect(
          @handler.establish_connection('baz', resolver.spec)
        ).to be_an_instance_of ActiveRecord::ConnectionAdapters::ConnectionPool
      end

    end

  end

  describe '#retrieve_connection' do

    context 'existing tenant' do

      it 'initializes and returns a connection' do
        expect(@handler.retrieve_connection('foo')).to be_true
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
        expect(@handler.retrieve_connection_pool('foo')).to be_true
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
      expect(@handler.connected?('foo')).to be_true
    end

    it 'returns false' do
      expect(@handler.connected?('foo')).to be_false
    end

  end

  describe '#active_connections?' do

    it 'has not active connections' do
      expect(@handler.active_connections?).to be_false
    end

    it 'has active connections' do
      @handler.retrieve_connection('foo')
      expect(@handler.active_connections?).to be_true
    end

  end

  describe '#remove_connection' do

    it 'removes the connection' do
      @handler.retrieve_connection('foo')
      expect(@handler.active_connections?).to be_true

      @handler.remove_connection('foo')
      expect(@handler.active_connections?).to be_false
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

end

