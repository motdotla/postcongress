ENV['RACK_ENV'] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
require File.expand_path(File.dirname(__FILE__) + "/factories")
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:each) do
    empty_database!
  end
end