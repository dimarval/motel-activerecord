require 'spec_helper'

describe Motel::ConnectionAdapters::ConnectionSpecification::Resolver do

  describe '#spec' do

    context 'from a hash' do

      before(:each) do
        @resolver = Motel::ConnectionAdapters::ConnectionSpecification::Resolver.new
      end

      context 'specifying adapter' do

        context 'existing adapter' do

          it 'returns an instance of ConnectionSpecification' do
            expect(
              @resolver.spec(BAZ_SPEC)
            ).to be_an_instance_of ActiveRecord::ConnectionAdapters::ConnectionSpecification
          end

        end

        context 'nonexistent adapter' do

          it 'rises an error' do
            expect{@resolver.spec({adapter: 'nonexistent_adapter'})}.to raise_error LoadError
          end

        end

      end

      context 'adapter unspecified' do

        it 'rises an error' do
          expect{
            @resolver.spec({database: BAZ_SPEC['database']})
          }.to raise_error ActiveRecord::AdapterNotSpecified
        end

      end

    end

    context 'from a string' do

      before(:each) do
        @resolver = Motel::ConnectionAdapters::ConnectionSpecification::Resolver.new(
          {'foo' => FOO_SPEC}
        )
      end

      context 'string as a key' do

        context 'existing configuration' do

          it 'returns an instance of ConnectionSpecification' do
            expect(
              @resolver.spec('foo')
            ).to be_an_instance_of ActiveRecord::ConnectionAdapters::ConnectionSpecification
          end

        end

        context 'nonexistent configuration' do

          it 'rises an error' do
            expect{@resolver.spec('baz')}.to raise_error ActiveRecord::AdapterNotSpecified
          end

        end

      end

      context 'string as a url' do

        before(:all) do
          @url = 'sqlite3://foo:foobar_password@localhost:3306/foobar'
        end

        it 'returns an instance of ConnectionSpecification' do
          expect(
            @resolver.spec(@url)
          ).to be_an_instance_of ActiveRecord::ConnectionAdapters::ConnectionSpecification
        end

        it 'spec of connection specifications contains a correct adapter' do
          expect(@resolver.spec(@url).config[:adapter]).to eq 'sqlite3'
        end

        it 'spec of connection specifications contains a correct username' do
          expect(@resolver.spec(@url).config[:username]).to eq 'foo'
        end

        it 'spec of connection specifications contains a correct password' do
          expect(@resolver.spec(@url).config[:password]).to eq 'foobar_password'
        end

        it 'spec of connection specifications contains a correct host' do
          expect(@resolver.spec(@url).config[:host]).to eq 'localhost'
        end

        it 'spec of connection specifications contains a correct port' do
          expect(@resolver.spec(@url).config[:port]).to eq 3306
        end

        it 'spec of connection specifications contains a correct database' do
          expect(@resolver.spec(@url).config[:database]).to eq 'foobar'
        end

      end

    end

  end

end

