require File.expand_path('../lib/sequel-etl/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name  = 'sequel-etl'
  gem.version = Sequel::ETL::VERSION
  gem.date  = '2014-02-19'
  gem.summary = "Sequel ETL"
  gem.description = "Ruby ETL using Sequel, inspired by Square's ETL gem"
  gem.authors = ["Michael J. Cohen","Denisse Cayetano"]
  gem.email = 'mjc@kernel.org'
  gem.files = ["lib/sequel-etl.rb"]
  gem.homepage  = 'http://rubygems.org/gems/sequel-etl'
  gem.licenses  = ["Apache License 2.0"]

  gem.add_dependency 'sequel'

  gem.add_development_dependency "rake"
  gem.add_development_dependency "pry"
  gem.add_development_dependency 'rspec', '~> 2.14'
end
