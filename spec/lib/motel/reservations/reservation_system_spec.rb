require 'spec_helper'

describe Motel::Reservations::ReservationSystem do

  before(:all) do
    @reservation_system = Motel::Reservations::ReservationSystem
  end

  after(:all) do
    Motel::Reservations::ReservationSystem.source = nil #sets default source
  end

  describe '#source_configurations' do

    context 'redis source' do

      before(:all) do
        @reservation_system.source_configurations(:redis, {
          host:                'localhost',
          port:                6380,
          password:            'none',
          path:                '/tmp/redis.sock',
          prefix_tenant_alias: 'test-tenant'
        })
      end

      it 'places a redis instance on the source' do
        expect(@reservation_system.source).to be_an_instance_of Motel::Reservations::Sources::Redis
      end

      it 'source attributes has a correct values' do
        expect(@reservation_system.source.host).to                eq 'localhost'
        expect(@reservation_system.source.port).to                eq 6380
        expect(@reservation_system.source.password).to            eq 'none'
        expect(@reservation_system.source.path).to                eq '/tmp/redis.sock'
        expect(@reservation_system.source.prefix_tenant_alias).to eq 'test-tenant'
      end

    end

    context 'database source' do

      before(:all) do
        @reservation_system.source_configurations(:database, {
          source_spec: TENANTS_SPEC,
          table_name:  'tenant'
        })
      end

      it 'places a database instance on the source' do
        expect(@reservation_system.source).to be_an_instance_of Motel::Reservations::Sources::Database
      end

      it 'source attributes has a correct values' do
        expect(@reservation_system.source.source_spec).to eq TENANTS_SPEC
        expect(@reservation_system.source.table_name).to  eq 'tenant'
      end

    end

  end

end

