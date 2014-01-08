ENV['RACK_ENV'] = 'test'

require 'spec_helper'
require 'rack/test'
require 'tempfile'

describe Motel::Lobby do
  include Rack::Test::Methods

  def app
    app = lambda{ |env| [200, {"Content-Type" => "text/html"}, "Test"] }
    Motel::Lobby.new(app)
  end

  before(:all) do
    ActiveRecord::Base.motel.add_tenant('foo', FOO_SPEC)
  end

  after(:all) do
    ActiveRecord::Base.motel.delete_tenant('foo')
    ActiveRecord::Base.motel.admission_criteria = nil #sets default
    ActiveRecord::Base.motel.nonexistent_tenant_page = nil #sets default
  end

  describe '#call' do

    context 'default admission criteria' do

      before(:all) do
        ActiveRecord::Base.motel.admission_criteria = nil
      end

      context 'url match' do

        context 'existing tenant' do

          before(:each) do
            @url = 'http://foo.test.com'
          end

          it 'sets the current tenant' do
            request @url

            expect(ActiveRecord::Base.motel.current_tenant).to eq 'foo'
          end

          it 'response is ok' do
            request  @url

            expect(last_response).to be_ok
          end

        end

        context 'nonexistent tenant' do

          before(:each) do
            @url = 'http://bar.test.com'
          end

          it 'returns 404 code' do
            request @url

            expect(last_response.status).to eq 404
          end

          context 'with default nonexistent tenant message' do

            it 'returns default message on body' do
              ActiveRecord::Base.motel.nonexistent_tenant_page = nil
              request @url

              expect(last_response.body).to eq "Nonexistent bar tenant"
            end

          end

          context 'specifying the path of the page with the nonexistent tenant message' do

            it 'returns default message on body' do
              message = '<h1>Noexistent tenant<h1>'
              file = Tempfile.new(['status_404', '.html'], TEMP_DIR)
              file.write(message)
              file.close

              ActiveRecord::Base.motel.nonexistent_tenant_page = file.path
              request @url

              expect(last_response.body).to eq message
            end

          end

        end

      end

    end

  end

  context 'specifying admission criteria' do

    before(:all) do
      ActiveRecord::Base.motel.admission_criteria = 'tenants\/(\w*)'
    end

    context 'url match' do

      context 'existing tenant' do

        before(:each) do
          @url = 'http://www.example.com/tenants/foo'
        end

        it 'sets the current tenant' do
          request @url

          expect(ActiveRecord::Base.motel.current_tenant).to eq 'foo'
        end

        it 'response is ok' do
          request  @url

          expect(last_response).to be_ok
        end

      end

    end

    context 'url does not match' do

      before(:each) do
        @url = 'http://example.com'
      end

      it 'sets null the current tenant' do
        request @url

        expect(ActiveRecord::Base.motel.current_tenant).to be_nil
     end

      it 'response is ok' do
        request  @url

        expect(last_response).to be_ok
      end

    end

  end

end

