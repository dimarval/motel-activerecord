version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.required_ruby_version = '~> 2.0'

  s.name        = 'motel-activerecord'
  s.version     = version
  s.platform    = Gem::Platform::RUBY
  s.date        = '2014-10-10'
  s.summary     = "Multi-tenant gem"
  s.description = "ActiveRecord extension to use connections to multiple databases"
  s.authors     = ["Diego Martínez Valdelamar"]
  s.email       = 'dimarva.90@gmail.com'
  s.files       = Dir["lib/**/*"] + ["VERSION", "README.md"]
  s.test_files  = Dir["spec/**/*"]
  s.homepage    = 'https://github.com/dimarval/motel-activerecord'
  s.license     = 'MIT'

  s.add_dependency 'activerecord', '~> 4.0'
  s.add_dependency 'activesupport', '~> 4.0'
  s.add_dependency 'redis', '~> 3.0.0'
  s.add_dependency 'rack', '~> 1.0'

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'sqlite3', '~> 1.0'
  s.add_development_dependency 'rack-test'

end

