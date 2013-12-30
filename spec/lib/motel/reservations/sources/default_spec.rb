require 'spec_helper'

describe Motel::Reservations::Sources::Default do

  before(:all) do
    @tenants_source = Motel::Reservations::Sources::Default.new
  end

  before(:each) do
    ActiveRecord::Base.configurations = {
      'foo' => FOO_SPEC,
      'bar' => BAR_SPEC
    }
    @config = ActiveRecord::Base.configurations
  end

  describe '#tenants' do

    it 'exist foo key' do
      expect(@tenants_source.tenants.key?('foo')).to be_true
    end

    it 'foo tenant has a correct spec' do
      expect(@tenants_source.tenants['foo']['adapter']).to eq FOO_SPEC['adapter']
      expect(@tenants_source.tenants['foo']['database']).to eq FOO_SPEC['database']
    end

    it 'exist bar key' do
      expect(@tenants_source.tenants.key?('foo')).to be_true
    end

    it 'bar tenant has a correct spec' do
      expect(@tenants_source.tenants['bar']['adapter']).to eq BAR_SPEC['adapter']
      expect(@tenants_source.tenants['bar']['database']).to eq BAR_SPEC['database']
    end

  end

  describe '#tenant' do

    it 'foo tenant has a correct spec' do
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

        it 'add new tenant to ActiveRecord::Base.configurations' do
          @tenants_source.add_tenant(
            'baz', {'adapter' => 'sqlite3', 'database' => 'tmp/baz.sqlite3'}
          )

          expect(@config.key?('baz')).to be_true
          expect(@config['baz']['adapter']).to eq 'sqlite3'
          expect(@config['baz']['database']).to eq 'tmp/baz.sqlite3'
        end

      end

      context 'spec has keys as symbols' do

        it 'add new tenant to ActiveRecord::Base.configurations' do
          @tenants_source.add_tenant(
            'baz', {adapter: 'sqlite3', database: 'tmp/baz.sqlite3'}
          )

          expect(@config.key?('baz')).to be_true
          expect(@config['baz']['adapter']).to eq 'sqlite3'
          expect(@config['baz']['database']).to eq 'tmp/baz.sqlite3'
        end

      end

    end

  end

  describe '#update_tenant' do

    context 'existing tenant' do

      context 'full update' do

        it 'update tenant to ActiveRecord::Base.configurations' do
          @tenants_source.update_tenant(
            'foo', {adapter: 'mysql2', database: 'foo'}
          )

          expect(@config['foo']['adapter']).to eq 'mysql2'
          expect(@config['foo']['database']).to eq 'foo'
        end

      end

      context 'partial update' do

        it 'update tenant to ActiveRecord::Base.configurations' do
          @tenants_source.update_tenant(
            'foo', {adapter: 'mysql2'}
          )

          expect(@config['foo']['adapter']).to eq 'mysql2'
          expect(@config['foo']['database']).to eq FOO_SPEC['database']
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

    it 'remove tenant from ActiveRecord::Base.configurations' do
      @tenants_source.delete_tenant('foo')

      expect(@config.key?('foo')).to be_false
    end

  end

end

