require 'spec_helper'

describe Motel::Reservations::Sources::Redis do

  before(:all) do
    @redis_server = ::Redis.new
    @prefix_tenant_alias = 'test-tenant:'
    @tenants_source = Motel::Reservations::Sources::Redis.new(
      prefix_tenant_alias: @prefix_tenant_alias
    )
  end

  before(:each) do
    @redis_server.hset "#{@prefix_tenant_alias}foo", 'adapter',  FOO_SPEC['adapter']
    @redis_server.hset "#{@prefix_tenant_alias}foo", 'database', FOO_SPEC['database']
    @redis_server.hset "#{@prefix_tenant_alias}bar", 'adapter',  BAR_SPEC['adapter']
    @redis_server.hset "#{@prefix_tenant_alias}bar", 'database', BAR_SPEC['database']
  end

  after(:each) do
    @redis_server.keys.each do |tenant_name|
      if tenant_name.match(@prefix_tenant_alias)
        fields = @redis_server.hkeys tenant_name
        @redis_server.hdel(tenant_name, [*fields])
      end
    end
  end

  describe '#tenants' do

    it 'there are only two tenants' do
      expect(@tenants_source.tenants.count).to eq 2
    end

    it 'exist foo key' do
      expect(@tenants_source.tenants.key?('foo')).to be_true
    end

    it 'tenant foo has a correct spec' do
      expect(@tenants_source.tenants['foo']['adapter']).to eq FOO_SPEC['adapter']
      expect(@tenants_source.tenants['foo']['database']).to eq FOO_SPEC['database']
    end

    it 'exist bar key' do
      expect(@tenants_source.tenants.key?('foo')).to be_true
    end

    it 'tenant bar has a correct spec' do
      expect(@tenants_source.tenants['bar']['adapter']).to eq BAR_SPEC['adapter']
      expect(@tenants_source.tenants['bar']['database']).to eq BAR_SPEC['database']
    end

  end

  describe '#tenant' do

    it 'tenant foo has a correct spec' do
      expect(@tenants_source.tenant('foo')['adapter']).to eq FOO_SPEC['adapter']
      expect(@tenants_source.tenant('foo')['database']).to eq FOO_SPEC['database']
    end

  end

  describe '#tenant?' do

    it 'returns true if tenant does exist' do
      expect(@tenants_source.tenant?('foo')).to be_true
    end

    it 'returns false if tenant does not exist' do
      expect(@tenants_source.tenant?('baz')).to be_false
    end

  end

  describe '#add_tenant' do

    context 'existing tenant' do

      it 'raise an error' do
        expect{
          @tenants_source.add_tenant('foo', FOO_SPEC)
        }.to raise_error Motel::ExistingTenantError
      end

    end

    context 'nonexistent tenant' do

      context 'spec has keys as strings' do

        it 'add new tenant to redis server' do
          @tenants_source.add_tenant(
            'baz', {'adapter'  => BAZ_SPEC['adapter'], 'database' => BAZ_SPEC['database']}
          )

          expect(@redis_server.hget("#{@prefix_tenant_alias}baz", 'adapter')).to eq BAZ_SPEC['adapter']
          expect(@redis_server.hget("#{@prefix_tenant_alias}baz", 'database')).to eq BAZ_SPEC['database']
        end

      end

      context 'spec has keys as symbols' do

        it 'add new tenant to redis server' do
          @tenants_source.add_tenant(
            'baz', {adapter:  BAZ_SPEC['adapter'] , database: BAZ_SPEC['database']}
          )

          expect(@redis_server.hget("#{@prefix_tenant_alias}baz", 'adapter')).to eq BAZ_SPEC['adapter']
          expect(@redis_server.hget("#{@prefix_tenant_alias}baz", 'database')).to eq BAZ_SPEC['database']
        end

      end

    end

  end

  describe '#update_tenant' do

    context 'existing tenant' do

      context 'full update' do

        it 'update tenant in teh redis server' do
          @tenants_source.update_tenant(
            'foo', {adapter: 'mysql2', database: 'foo'}
          )

          expect(@redis_server.hget("#{@prefix_tenant_alias}foo", 'adapter')).to eq 'mysql2'
          expect(@redis_server.hget("#{@prefix_tenant_alias}foo", 'database')).to eq 'foo'
        end

      end

      context 'partial update' do

        it 'update tenant in the redis server' do
          @tenants_source.update_tenant(
            'foo', {adapter: 'mysql2'}
          )

          expect(@redis_server.hget("#{@prefix_tenant_alias}foo", 'adapter')).to eq 'mysql2'
          expect(@redis_server.hget("#{@prefix_tenant_alias}foo", 'database')).to eq FOO_SPEC['database']
        end

      end

    end

    context 'nonexistent tenant' do

      it 'raise an error' do
        expect{
          @tenants_source.update_tenant('baz', {})
        }.to raise_error Motel::NonexistentTenantError
      end

    end

  end

  describe '#delete_tenant' do

    it 'remove tenant from redis server' do
      @tenants_source.delete_tenant('foo')

      expect(@redis_server.hexists("#{@prefix_tenant_alias}foo", 'adapter')).to be_false
      expect(@redis_server.hexists("#{@prefix_tenant_alias}foo", 'database')).to be_false
    end

  end

end

