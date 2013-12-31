require File.expand_path("../../lib/motel", __FILE__)

TENANTS_SPEC = {'adapter' => 'sqlite3', 'database' => 'spec/tmp/tenants.sqlite3'}

FOO_SPEC = {'adapter' => 'sqlite3', 'database' => 'spec/tmp/foo.sqlite3'}
BAR_SPEC = {'adapter' => 'sqlite3', 'database' => 'spec/tmp/bar.sqlite3'}
BAZ_SPEC = {'adapter' => 'sqlite3', 'database' => 'spec/tmp/baz.sqlite3'}

RSpec.configure do |config|
  config.color_enabled = true
end

