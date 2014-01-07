require 'spec_helper'
require 'rack/test'


module RSpecMixin
  include Rack::Test::Methods
  def app
    app = lambda{ |env| [200, {"Content-Type" => "text/html"}, "Test"] }
    Motel::Lobby.new(app)
  end
end

RSpec.configure { |c| c.include RSpecMixin }


describe Motel::Lobby do

  before(:all) do
    ActiveRecord::Base.motel.add_tenant('foo', FOO_SPEC)
  end

  after(:all) do
    ActiveRecord::Base.motel.delete_tenant('foo')
  end

  describe '#call' do

    context 'url match with the admission criteria' do

      before(:each) do
        @url = 'http://foo.test.com'
      end

      context 'existing tenant' do

        it 'sets the current tenant' do
          request @url
          puts last_request.url

          expect(ActiveRecord::Base.motel.current_tenant).to eq 'foo'
        end

        it 'returns 202 code'

      end

      context 'nonexistent tenant' do

        it 'returns 404 code'

      end

    end

    context 'url does not match with the admission criteria' do

      it 'sets null the current tenant'

      it 'returns 202 code'

    end

  end

end

