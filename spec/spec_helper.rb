require File.expand_path("../../lib/motel-activerecord", __FILE__)

TEMP_DIR = File.expand_path("../tmp/", __FILE__)

TENANTS_SPEC = {'adapter' => 'sqlite3', 'database' => 'spec/tmp/tenants.sqlite3'}

FOO_SPEC = {'adapter' => 'sqlite3', 'database' => "#{TEMP_DIR}/foo.sqlite3"}
BAR_SPEC = {'adapter' => 'sqlite3', 'database' => "#{TEMP_DIR}/bar.sqlite3"}
BAZ_SPEC = {'adapter' => 'sqlite3', 'database' => "#{TEMP_DIR}/baz.sqlite3"}

RSpec.configure do |config|
  config.color = true
end

