$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "xml_dsl/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "xml_dsl"
  s.version     = XmlDsl::VERSION
  s.authors     = ["Vladislav Bogomolov"]
  s.email       = ["vladson4ik@gmail.com"]
  s.summary     = "Create easy xml mappers to hash via Nokogiri::XML"
  s.description = "DSL designed for easily create XML mappers"
  s.homepage    = "https://github.com/vladson/xml_dsl"
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "nokogiri", "~> 1.6"

  s.add_development_dependency "rspec", '~> 2.4'
  s.add_development_dependency "guard", '~> 2.8'
  s.add_development_dependency "guard-rspec", '~> 4.3'
  s.add_development_dependency "pry", '~> 0.1'
  s.add_development_dependency "pry-remote", '~> 0.1'
  s.add_development_dependency "pry-nav", '~> 0.2'
  s.test_files = Dir["spec/**/*"]
end
