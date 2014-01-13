require 'spec_helper'

describe Motel::ReservationSystem do

  before(:all) do
    @reservation_system = Motel::ReservationSystem.new
  end

  describe '#source_configurations' do

    context 'redis source' do

      before(:all) do
        @reservation_system.source_configurations({
          source:              :redis,
          host:                'localhost',
          port:                6380,
          password:            'none',
          path:                '/tmp/redis.sock',
          prefix_tenant_alias: 'test-tenant'
        })
      end

      it 'places a redis instance on the source' do
        expect(@reservation_system.source).to be_an_instance_of Motel::Sources::Redis
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
        @reservation_system.source_configurations({
          source:      :database,
          source_spec: TENANTS_SPEC,
          table_name:  'tenant'
        })
      end

      it 'places a database instance on the source' do
        expect(@reservation_system.source).to be_an_instance_of Motel::Sources::Database
      end

      it 'source attributes has a correct values' do
        expect(@reservation_system.source.source_spec).to eq TENANTS_SPEC
        expect(@reservation_system.source.table_name).to  eq 'tenant'
      end

    end

    context 'default source' do

      before(:all) do
        @reservation_system.source_configurations({source: :default})
      end

      it 'places a default instance on the source' do
        expect(@reservation_system.source).to be_an_instance_of Motel::Sources::Default
      end

    end

  end

end

