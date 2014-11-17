require 'bundler/setup'
require 'nokogiri'
require 'pry'
Bundler.setup

require 'xml_dsl' # and any other gems you need

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = "random"
end