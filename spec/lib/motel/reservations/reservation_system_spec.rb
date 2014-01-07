require 'spec_helper'

describe Motel::Reservations::ReservationSystem do

  describe '#source_configurations' do

    context 'redis source' do

      before(:all) do
        @source = Motel::Reservations::ReservationSystem.source(:redis, {
          host:                'localhost',
          port:                6380,
          password:            'none',
          path:                '/tmp/redis.sock',
          prefix_tenant_alias: 'test-tenant'
        })
      end

      it 'places a redis instance on the source' do
        expect(@source).to be_an_instance_of Motel::Reservations::Sources::Redis
      end

      it 'source attributes has a correct values' do
        expect(@source.host).to                eq 'localhost'
        expect(@source.port).to                eq 6380
        expect(@source.password).to            eq 'none'
        expect(@source.path).to                eq '/tmp/redis.sock'
        expect(@source.prefix_tenant_alias).to eq 'test-tenant'
      end

    end

    context 'database source' do

      before(:all) do
        @source = Motel::Reservations::ReservationSystem.source(:database, {
          source_spec: TENANTS_SPEC,
          table_name:  'tenant'
        })
      end

      it 'places a database instance on the source' do
        expect(@source).to be_an_instance_of Motel::Reservations::Sources::Database
      end

      it 'source attributes has a correct values' do
        expect(@source.source_spec).to eq TENANTS_SPEC
        expect(@source.table_name).to  eq 'tenant'
      end

    end

  end

end

