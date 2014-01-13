require 'spec_helper'

describe Motel::ConnectionAdapters::ConnectionSpecification::Resolver do

  before(:all) do
    @tenants_source = Motel::Sources::Default.new
    @resolver = Motel::ConnectionAdapters::ConnectionSpecification::Resolver.new(@tenants_source)
  end

  before(:each) do
    @tenants_source.add_tenant('foo', FOO_SPEC)
    @tenants_source.add_tenant('bar', BAR_SPEC)
  end

  after(:each) do
    @tenants_source.tenants.keys.each do |tenant_name|
      @tenants_source.delete_tenant(tenant_name)
    end
  end

  describe '#spec' do

    context 'existing tenant' do

      context 'specifying adapter' do

        context 'existing adapter' do

          it 'returns an instance of ConnectionSpecification' do
            expect(
              @resolver.spec('foo')
            ).to be_an_instance_of ActiveRecord::ConnectionAdapters::ConnectionSpecification
          end

        end

        context 'nonexistent adapter' do

          it 'rises an error' do
            @tenants_source.update_tenant('foo', {adapter: 'nonexistent_adapter'})

            expect{@resolver.spec('foo')}.to raise_error LoadError
          end

        end

      end

      context 'adapter unspecified' do

        it 'rises an error' do
          @tenants_source.add_tenant('baz', {database: BAZ_SPEC['database']})

          expect{
            @resolver.spec('baz')
          }.to raise_error ActiveRecord::AdapterNotSpecified
        end

      end

    end

    context 'nonexistent tenant' do

      it 'rises an error' do
        expect{@resolver.spec('baz')}.to raise_error Motel::NonexistentTenantError
      end

    end

  end

end

