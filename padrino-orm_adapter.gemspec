$:.push File.expand_path("../lib", __FILE__)
require "padrino/orm_adapter/version"

Gem::Specification.new do |s|
  s.name = "padrino-orm_adapter"
  s.version = Padrino::OrmAdapter::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.authors = ["Ian White", "Jose Valim"]
  s.description = "Provides a single point of entry for using basic features of ruby ORMs"
  s.summary = "orm_adapter provides a single point of entry for using basic features of popular ruby ORMs.  Its target audience is gem authors who want to support many ruby ORMs."
  s.email = "ian.w.white@gmail.com"
  s.homepage = "http://github.com/namusyaka/padrino-orm_adapter"
  s.license = "MIT"

  s.required_rubygems_version = ">= 1.3.6"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake', '>= 0.8.7'
  s.add_development_dependency 'rspec', '>= 3.0.0'

  if RUBY_ENGINE == 'jruby'
    s.add_development_dependency "jdbc-sqlite3", "~> 3.7.2"
  else
    s.add_development_dependency "sqlite3", '>= 1.3.2'
  end
end
