Motel (Multi-Tenant)
===================

Motel is a gem that adds functionality to ActiveRecord to use
connections to multiple databases, one for each tenant.

# Features

* Add functionality multi-tenant to ActiveRecord.
* Multiple databases, one for each tenant.
* Tenant connection details are stored keying them by the name on a database or redis server.
* Use with or without Rails.

# Installing

```
Run the following if you haven't done so before:
gem sources -a http://gems.github.com/

Install the gem:
sudo gem install motel
```

# Configuration

## Use with Rails

In your app/application.rb file write this:

### Specifying database as a source of tenants

```ruby
config.motel.source_configurations :data_base do |c|
  c.source = config.database_configuration[Rails.env]
  c.table_name = 'tenants'
end
```

You can specify the source by providing a hash of the data
connection as a specification of ActiveRecord, example:

```ruby
c.source = {adapter: 'sqlite3', database: 'db/tenants.sqlite3'}
```

Table name where are stored the connection details of tenants:

```ruby
c.table_name = 'tenants'
```

Note: The columns of the table must contain connection details are
according to the information needed to connect to a database
including the name of the tenant. Fields available are listed
below:


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

Another option is to create the table using the utility:

```ruby
ActiveRecord::Base.motel.create_tenant_table
```

### Specifying a redis-server as a source of tenants

```ruby
config.motel.source_configurations :redis do |c|
  c.host = 127.0.0.1
  c.port = 6380
  c.password = 'redis_password'
end
```
To connect to Redis listening on a Unix socket, try use 'path'
option.

### Default source of tenants

Default tenants are obtained from the file `config/database.yml`.
The actions like `add_tenant`, `update_tenant` and `delete_tenant`
are not stored or modified in the file.

### More configurations

You can assign a default tenant if the current tenant is null:

```ruby
config.motel.default_tenant = 'my_default_tenant'
```

Tenants switching is done via the subdomain of the url, you can
specify a criteria to identify the tenant providing a regex.
Example, to get the tenant the following url
`test-my_tenant_name.domain.com` you should write:

```ruby
config.motel.admission_criteria = /\w*-{1}(\w*)\.{1}\w*/
```

To disable automatic switching between tenants by url:

```ruby
config.motel.disable_middleware = true
```

Path of the web page to show if nonexistent tenant. Default is
`public/404.html`.

```ruby
config.motel.nonexistent_tenant_page = 'new_path'
```

## Use without Rails

### Specifying the source of tenants

You can set the source of the tenants in the same way as with Rails, all you have you do is change the `config` method for `ActiveRecord::Base.motel`:

```ruby
ActiveRecord::Base.motel.source_configurations :data_base do |c|
  c.source = {adapter: 'sqlite3', database: 'db/tenants.sqlite3'}
  c.table_name = 'tenants'
end
```

# Usage

Set a default tenant
```ruby
ActiveRecord::Base.motel.default_tenant
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
ActiveRecord::Base.motel.add_tenant(name, spec, expiration)
```

Update tenant
```ruby
ActiveRecord::Base.motel.update_tenant(name, spec, expiration)
```

Delete tenant
```ruby
ActiveRecord::Base.motel.delete_tenant(name)
```

Create tenant table
```ruby
ActiveRecord::Base.motel.create_tenant_table
```

Destroy tenant table
```ruby
ActiveRecord::Base.motel.delete_tenant_table
```

Retrieve the names of the tenants of active connections
```ruby
ActiveRecord::Base.motel.active_tenants
```

Determine the tenant to use for the connection
```ruby
ActiveRecord::Base.motel.determines_tenant
```


