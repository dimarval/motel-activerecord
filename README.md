Motel-ActiveRecord
===================

Motel is a gem that adds functionality to ActiveRecord to use
connections to multiple databases, one for each tenant.

# Features

* Adds multi-tenant functionality to ActiveRecord.
* Multiple databases, one for each tenant.
* Databases of tenants may be in different locations.
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

# SemVer

This gem is based on the [Semantic Versioning](http://semver.org/).

# Configuration

## Use with Rails

In your app/application.rb file write this:

### Specifying database as a source of tenants

```ruby
config.motel.tenants_source_configurations = {
  source:      :database,
  source_spec: { adapter: "sqlite3", database: "db/tenants.sqlite3" },
  table_name:  "tenant"
}
```

You can specify the source by providing a hash of the
connection specification. Example:

```ruby
source_spec: { adapter: "sqlite3", database: "db/tenants.sqlite3" }
```

Table name where are stored the connection details of tenants:

```ruby
table_name: "tenant"
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
| host      | String    |
| username  | String    |
| password  | String    |
| database  | String    |
| url       | String    |


### Specifying a redis-server as a source of tenants

```ruby
config.motel.tenants_source_configurations = {
  source:   :redis,
  host:     127.0.0.1,
  port:     6380,
  password: "redis_password"
}
```
To connect to Redis listening on a Unix socket, try use 'path'
option.

### Default source of tenants

Also you can use the gem without specify a source configuration.

If you want to assing dirently the tenants specificactions you can do it:

```ruby
config.motel.tenants_source_configurations = {
  configurations: { "foo" => { adapter: "sqlite3", database: "db/foo.sqlite3" } }
}
```

Assing tenants from database.yml file:

```ruby
config.motel.tenants_source_configurations = {
  configurations: Rails.application.config.database_configuration
}
```

Note: The methods like `add_tenant`, `update_tenant` and
`delete_tenant` dosen't store permanently tenants.

### Use rake task

Set the `TENANT` environment variable to run the rake task on a
specific tenant.

```ruby
$ TENANT=foo rake db:migrate
```

To create the database of all tenants.

```ruby
rake db:create:all
```

To drop the database of all tenants.

```ruby
rake db:drop:all
```

(Note: Is necessary to establish a **default tenant** because the
middlewares of ActiveRecord require a connection to function
properly and shared pages between tenants can be viewed.)

## Use without Rails

### Specifying the source of tenants

You can set the source of the tenants in the same way as with Rails,
use the method `tenants_source_configurations` of `Motel::Manager`:

```ruby
Motel::Manager.tenants_source_configurations({
  source:      :database,
  source_spec: { adapter: "sqlite3", database: "db/tenants.sqlite3" },
  table_name:  'tenant'
})
```

# Usage

## Switching tenants

To switch between tenants:

```ruby
Motel::Manager.switch_tenant("foo")
```

To determine the tenant of the connection to retrieve a fallback is
performed through the variables that are used to set the tenant in
the following order: environment variable `ENV['TENANT']`,
tenant switched `Motel::Manager.switch_tenant()` and default tenant
`Motel::Manager.default_tenant`.

Usage example:

```ruby
  Motel::Manager.switch_tenant("foo")

  FooBar.create(name: "Foo")
  # => #<FooBar id: 1, name: "Foo">

  Motel::Manager.switch_tenant("bar")

  FooBar.all
  # => #<ActiveRecord::Relation []>

  Motel::Manager.switch_tenant("foo")

  FooBar.all
  # => #<ActiveRecord::Relation [#<FooBar id: 1, name: "Foo">]>
```

# Available methods

Sets a tenats source configurations

```ruby
Motel::Manager.tenants_source_configurations(config)
```

Switches the tenant

```ruby
Motel::Manager.switch_tenant(name)
```

Sets a default tenant

```ruby
Motel::Manager.default_tenant
```

Retrieves a current tenant

```ruby
Motel::Manager.current_tenant
```

Retrieves the connection details of all tenants

```ruby
Motel::Manager.tenants
```

Retrieves a tenant

```ruby
Motel::Manager.tenant(name)
```

Determines if a tenant exists

```ruby
Motel::Manager.tenant?(name)
```

Adds tenant

```ruby
Motel::Manager.add_tenant(name, spec)
```

Updates tenant

```ruby
Motel::Manager.update_tenant(name, spec)
```

Deletes tenant

```ruby
Motel::Manager.delete_tenant(name)
```

Retrieves the names of the tenants of active connections

```ruby
Motel::Manager.active_tenants
```

