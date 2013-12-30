require File.expand_path("../../lib/motel", __FILE__)

FOO_SPEC = {'adapter' => 'sqlite3', 'database' => 'tmp/foo.sqlite3'}
BAR_SPEC = {'adapter' => 'sqlite3', 'database' => 'tmp/bar.sqlite3'}

RSpec.configure do |config|
  config.color_enabled = true
end

