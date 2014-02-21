Gem::Specification.new do |s|
  s.name        = 'motel-activerecord'
  s.version     = '1.0.0'
  s.platform    = Gem::Platform::RUBY
  s.date        = '2014-02-21'
  s.summary     = "Multi-tenant gem"
  s.description = "ActiveRecord extension to use connections to multiple databases"
  s.authors     = ["Diego Martínez Valdelamar"]
  s.email       = 'dimarva.90@gmail.com'
  s.files       = Dir["lib/**/*"]
  s.test_files  = Dir["test/**/*"]
  s.homepage    = 'https://github.com/dimarval/motel-activerecord'
  s.license     = 'MIT'

  s.add_dependency 'activerecord', '>= 4.0', '<= 5.0'
  s.add_dependency 'activesupport'
  s.add_dependency 'redis'

  s.add_development_dependency 'rspec'
end
