Gem::Specification.new do |s|
  s.name        = 'motel'
  s.version     = '0.0.0'
  s.date        = '2010-11-25'
  s.summary     = "Multi-tenant gem"
  s.description = "ActiveRecord extension to use connections to multiple databases"
  s.authors     = ["Diego Martínez Valdelamar"]
  s.email       = 'dimarva.90@gmail.com'
  s.files       = Dir["lib/**/*"]
  s.test_files  = Dir["test/**/*"]
  s.homepage    = 'https://github.com/dimarval/motel'
  s.license     = 'MIT' 

  s.add_dependency 'activerecord', '>= 3.0', '<= 5.0'
  s.add_dependency 'activesupport'
  s.add_dependency 'redis'

end
