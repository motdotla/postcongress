ENV["RACK_ENV"] ||= "development"

require 'bundler'
Bundler.setup

Bundler.require(:default, ENV["RACK_ENV"].to_sym)

Dotenv.load

require './config/recursive_openstruct'
require './config/constants'
require './config/redis'
require './config/stripe'
require './config/sunlight'

Dir["./lib/*.rb"].each { |f| require f }

require './app/application'

Dir["./app/*.rb"].each { |f| require f }
Dir["./app/models/*.rb"].each { |f| require f }
