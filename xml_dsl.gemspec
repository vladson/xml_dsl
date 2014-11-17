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

  s.add_development_dependency "rspec"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-remote"
  s.add_development_dependency "pry-nav"
  s.test_files = Dir["spec/**/*"]
end
