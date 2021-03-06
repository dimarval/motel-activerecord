require 'spec_helper'

describe Motel::Sources::Default do

  before(:each) do
    @tenants_source = Motel::Sources::Default.new(
      configurations: {'foo' => FOO_SPEC, 'bar' => BAR_SPEC }
    )
  end

  describe '#tenants' do

    it 'exist foo key' do
      expect(@tenants_source.tenants.key?('foo')).to be_truthy
    end

    it 'tenant foo has a correct spec' do
      expect(@tenants_source.tenants['foo']['adapter']).to eq FOO_SPEC['adapter']
      expect(@tenants_source.tenants['foo']['database']).to eq FOO_SPEC['database']
    end

    it 'exist bar key' do
      expect(@tenants_source.tenants.key?('bar')).to be_truthy
    end

    it 'tenant bar has a correct spec' do
      expect(@tenants_source.tenants['bar']['adapter']).to eq BAR_SPEC['adapter']
      expect(@tenants_source.tenants['bar']['database']).to eq BAR_SPEC['database']
    end

  end

  describe '#tenant' do

    context 'existing tenant' do

      it 'tenant foo has a correct spec' do
        expect(@tenants_source.tenant('foo')['adapter']).to eq FOO_SPEC['adapter']
        expect(@tenants_source.tenant('foo')['database']).to eq FOO_SPEC['database']
      end

    end

    context 'nonexistent tenant' do

      it 'returns null' do
        expect(@tenants_source.tenant('baz')).to be_nil
      end

    end

  end

  describe '#tenant?' do

    it 'returns true if tenant does exist' do
      expect(@tenants_source.tenant?('foo')).to be_truthy
    end

    it 'returns false if tenant does not exist' do
      expect(@tenants_source.tenant?('baz')).to be_falsey
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

        it 'add new tenant to ActiveRecord::Base.configurations' do
          @tenants_source.add_tenant(
            'baz', {'adapter' => BAZ_SPEC['adapter'], 'database' => BAZ_SPEC['database']}
          )

          expect(@tenants_source.tenants.key?('baz')).to be_truthy
          expect(@tenants_source.tenants['baz']['adapter']).to eq BAZ_SPEC['adapter']
          expect(@tenants_source.tenants['baz']['database']).to eq BAZ_SPEC['database']
        end

      end

      context 'spec has keys as symbols' do

        it 'add new tenant to ActiveRecord::Base.configurations' do
          @tenants_source.add_tenant(
            'baz', {adapter: BAZ_SPEC['adapter'], database: BAZ_SPEC['database']}
          )

          expect(@tenants_source.tenants.key?('baz')).to be_truthy
          expect(@tenants_source.tenants['baz']['adapter']).to eq BAZ_SPEC['adapter']
          expect(@tenants_source.tenants['baz']['database']).to eq BAZ_SPEC['database']
        end

      end

    end

  end

  describe '#update_tenant' do

    context 'existing tenant' do

      context 'full update' do

        it 'update tenant from ActiveRecord::Base.configurations' do
          @tenants_source.update_tenant(
            'foo', {adapter: 'mysql2', database: 'foo'}
          )

          expect(@tenants_source.tenants['foo']['adapter']).to eq 'mysql2'
          expect(@tenants_source.tenants['foo']['database']).to eq 'foo'
        end

      end

      context 'partial update' do

        it 'update tenant from ActiveRecord::Base.configurations' do
          @tenants_source.update_tenant(
            'foo', {adapter: 'mysql2'}
          )

          expect(@tenants_source.tenants['foo']['adapter']).to eq 'mysql2'
          expect(@tenants_source.tenants['foo']['database']).to eq FOO_SPEC['database']
        end

      end

    end

    context 'nonexistent tenant' do

      it 'raise an error' do
        expect{
          @tenants_source.update_tenant('baz', BAZ_SPEC)
        }.to raise_error Motel::NonexistentTenantError
      end

    end

  end

  describe '#delete_tenant' do

    it 'remove tenant from ActiveRecord::Base.configurations' do
      @tenants_source.delete_tenant('foo')

      expect(@tenants_source.tenants.key?('foo')).to be_falsey
    end

  end

end

