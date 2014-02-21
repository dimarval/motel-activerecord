Motel ActiveRecord
===================

Motel is a gem that adds functionality to ActiveRecord to use
connections to multiple databases, one for each tenant.

# Features

* Adds multi-tenant functionality to ActiveRecord.
* Multiple databases, one for each tenant.
* Tenant connection details are stored keying them by the name on a database or redis server.
* Use with or without Rails.

# Installing

```ruby
gem install motel-activerecord
```

or add the following line to Gemfile:

```ruby
gem 'motel-activerecord'
```

and run `bundle install` from your shell.

# Supported Ruby and Rails versions
The gem motel-activerecord supports MRI Ruby 2.0 or greater and Rails 4.0 or greater.
 
# Configuration

## Use with Rails

In your app/application.rb file write this:

### Specifying database as a source of tenants

```ruby
config.motel.tenants_source_configurations = {
  source:      :database,
  source_spec: { adapter: 'sqlite3', database: 'db/tenants.sqlite3' },
  table_name:  'tenant'
}
```

You can specify the source by providing a hash of the
connection specification. Example:

```ruby
source_spec: {adapter: 'sqlite3', database: 'db/tenants.sqlite3'}
```

Table name where are stored the connection details of tenants:

```ruby
table_name: 'tenant'
```

Note: The columns of the table must contain connection details and
thad are according with the information needed to connect to a database,
including the name column to store the tenant name. Example columns 
are showed below:

|Name       |Type       |
| ----------|:---------:|
| name      | String    |
| adapter   | String    |
| sockect   | String    |
| port      | Integer   |
| pool      | Integer   |
| host      | Integer   |
| username  | Integer   |
| password  | Integer   |
| database  | Integer   |
| url       | String    |


### Specifying a redis-server as a source of tenants

```ruby
config.motel.tenants_source_configurations = {
  source:   :redis,
  host:     127.0.0.1,
  port:     6380,
  password: 'redis_password'
}
```
To connect to Redis listening on a Unix socket, try use 'path'
option.

### Default source of tenants

Also you can use the gem without specify a source configuration. 

If you want to assing dirently the tenants specificactions you can do it:

```ruby
config.motel.tenants_source_configurations = {
  tenant: { 'foo' => { adapter: 'sqlite3', database: 'db/foo.sqlite3' }}
}
```

Assing tenants from database.yml file:

```ruby
config.motel.tenants_source_configurations = {
  tenant: Rails.application.config.database_configuration
}
```

Note: The methods like `add_tenant`, `update_tenant` and 
`delete_tenant` dosen't store permanently tenants.

### More configurations

You can assign a default tenant if the current tenant is null:

```ruby
config.motel.default_tenant = 'my_default_tenant'
```

Tenants switching is done via the subdomain of the url, you can
specify a criteria to identify the tenant providing a regex as a 
string. Example, to get the tenant `foo` from the following url
`http://www.example.com/foo/index` you should write:

```ruby
config.motel.admission_criteria = '\/(\w*)\/'
```

To disable automatic switching between tenants by url you must
disable the middleware:

```ruby
config.motel.disable_middleware = true
```

Path of the html page to show if tenant doesn't exist. Default is
`public/404.html`.

```ruby
config.motel.nonexistent_tenant_page = 'new_path'
```

## Use without Rails

### Specifying the source of tenants

You can set the source of the tenants in the same way as with Rails, use the method `tenants_source_configurations` of `ActiveRecord::Base.motel`:

```ruby
ActiveRecord::Base.motel.tenants_source_configurations({
  source:      :database,
  source_spec: { adapter: 'sqlite3', database: 'db/tenants.sqlite3' },
  table_name:  'tenant'
})
```

# Available methods

Set a tenats source configurations
```ruby
ActiveRecord::Base.motel.tenants_source_configurations(config)
```

Set the admission criterio for the middleware
```ruby
ActiveRecord::Base.motel.admission_criterio
```

Set a default tenant
```ruby
ActiveRecord::Base.motel.default_tenant
```

Set the html page to show if tenant doesn't exist
```ruby
ActiveRecord::Base.motel.nonexistent_tenant_page
```

Set a current tenant
```ruby
ActiveRecord::Base.motel.current_tenant
```

Retrieve the connection details of all tenants
```ruby
ActiveRecord::Base.motel.tenants
```

Retrieve a tenant
```ruby
ActiveRecord::Base.motel.tenant(name)
```

Determine if a tenant exists
```ruby
ActiveRecord::Base.motel.tenant?(name)
```

Add tenant
```ruby
ActiveRecord::Base.motel.add_tenant(name, spec)
```

Update tenant
```ruby
ActiveRecord::Base.motel.update_tenant(name, spec)
```

Delete tenant
```ruby
ActiveRecord::Base.motel.delete_tenant(name)
```

Retrieve the names of the tenants of active connections
```ruby
ActiveRecord::Base.motel.active_tenants
```

Determine the tenant to use for the connection
```ruby
ActiveRecord::Base.motel.determines_tenant
```