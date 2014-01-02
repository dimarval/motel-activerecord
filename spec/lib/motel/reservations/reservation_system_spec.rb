require 'spec_helper'

describe Motel::Reservations::ReservationSystem do

  before(:all) do
    @reservation_system =  Motel::Reservations::ReservationSystem.new
  end

  describe '#source_configurations' do

    context 'redis source' do

      before(:all) do
        @reservation_system.source_configurations :redis do |c|
          c.host = 'localhost'
          c.port = 6380
          c.password = 'none'
          c.path = '/tmp/redis.sock'
          c.prefix_tenant_alias = 'test-tenant'
        end
      end

      it 'places a redis instance on the source' do
        expect(@reservation_system.source).to be_an_instance_of Motel::Reservations::Sources::Redis
      end

      it 'source attributes has a correct values' do
        expect(@reservation_system.source.host).to eq 'localhost'
        expect(@reservation_system.source.port).to eq 6380
        expect(@reservation_system.source.password).to eq 'none'
        expect(@reservation_system.source.path).to eq '/tmp/redis.sock'
        expect(@reservation_system.source.prefix_tenant_alias).to eq 'test-tenant'
      end

    end

    context 'database source' do

      before(:all) do
        @reservation_system.source_configurations :database do |c|
          c.source_spec = TENANTS_SPEC
          c.table_name  = 'tenant'
        end
      end

      it 'places a database instance on the source' do
        expect(@reservation_system.source).to be_an_instance_of Motel::Reservations::Sources::Database
      end

      it 'source attributes has a correct values' do
        expect(@reservation_system.source.source_spec).to eq TENANTS_SPEC
        expect(@reservation_system.source.table_name).to eq 'tenant'
      end

    end

  end

  context 'source is configured' do

    before(:all) do
      @reservation_system.source_configurations :default do
      end
    end

    before(:each) do
      ActiveRecord::Base.configurations = {
        'foo' => FOO_SPEC,
        'bar' => BAR_SPEC
      }
    end

    describe '#tenants' do

      it 'exist foo key' do
        expect(@reservation_system.tenants.key?('foo')).to be_true
      end

      it 'tenant foo has a correct spec' do
        expect(@reservation_system.tenants['foo']['adapter']).to eq FOO_SPEC['adapter']
        expect(@reservation_system.tenants['foo']['database']).to eq FOO_SPEC['database']
      end

      it 'exist bar key' do
        expect(@reservation_system.tenants.key?('bar')).to be_true
      end

      it 'tenant bar has a correct spec' do
        expect(@reservation_system.tenants['bar']['adapter']).to eq BAR_SPEC['adapter']
        expect(@reservation_system.tenants['bar']['database']).to eq BAR_SPEC['database']
      end

    end

    describe '#tenant' do

      it 'tenant foo has a correct spec' do
        expect(@reservation_system.tenant('foo')['adapter']).to eq FOO_SPEC['adapter']
        expect(@reservation_system.tenant('foo')['database']).to eq FOO_SPEC['database']
      end

    end

    describe '#tenant?' do

      it 'returns true if tenant does exist' do
        expect(@reservation_system.tenant?('foo')).to be_true
      end

      it 'returns false if tenant does not exist' do
        expect(@reservation_system.tenant?('baz')).to be_false
      end

    end

    describe '#add_tenant' do

      context 'existing tenant' do

        it 'raise an error' do
          expect{
            @reservation_system.add_tenant('foo', FOO_SPEC)
          }.to raise_error Motel::ExistingTenantError
        end

      end

      context 'nonexistent tenant' do

        it 'returns true' do
          expect(@reservation_system.add_tenant('baz', BAZ_SPEC)).to be_true
        end

      end

    end

    describe '#update_tenant' do

      context 'existing tenant' do

        it 'returns true' do
          expect(@reservation_system.update_tenant('foo', {adapter: 'mysql2'})).to be_true
        end

      end

      context 'nonexistent tenant' do

        it 'raise an error' do
          expect{
            @reservation_system.update_tenant('baz', BAZ_SPEC)
          }.to raise_error Motel::NonexistentTenantError
        end

      end

    end

    describe '#delete_tenant' do

      it 'returns true' do
        expect(@reservation_system.delete_tenant('foo')).to be_true
      end

    end

  end

end

