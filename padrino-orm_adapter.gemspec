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

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "git", ">= 1.2.5"
  s.add_development_dependency "yard", ">= 0.6.0"
  s.add_development_dependency "rake", ">= 0.8.7"
  s.add_development_dependency "activerecord", ">= 3.2.15"
  s.add_development_dependency "mongoid", "~> 2.8.0"
  s.add_development_dependency "mongo_mapper", "~> 0.11.0"
  s.add_development_dependency "rspec", ">= 2.4.0"
  s.add_development_dependency "datamapper", ">= 1.0"
  s.add_development_dependency "dm-sqlite-adapter", ">= 1.0"
  s.add_development_dependency "dm-active_model", ">= 1.0"
  s.add_development_dependency "sequel", "~> 4.11"
  s.add_development_dependency "dynamoid", "~> 0.7.1"
  s.add_development_dependency "fake_dynamo", "~> 0.1.4"
  s.add_development_dependency "mini_record", "~> 0.4.5"
end
