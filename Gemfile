source "https://rubygems.org" 
ruby "1.9.3"

gem 'activemodel', require: 'active_model'
gem 'aws-sdk'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'docsplit'
gem 'dotenv'
gem 'foreman'
gem 'haml'
gem 'heroku'
gem 'json'
gem 'jsonify',          require: %w(jsonify jsonify/tilt)
gem 'less'
gem 'pry'
gem 'pusher'
gem 'racksh'
gem 'rake'
gem 'redis'
gem 'redis-store'
gem 'rest-client'
gem 'sidekiq',          git: 'https://github.com/mperham/sidekiq.git', ref: '83bdf72acce82eea1d35397ac15c2d092ad6543d', require: %w(sidekiq sidekiq/web)
gem 'sinatra',          require: 'sinatra/base'
gem 'slim'
gem 'sprockets'
gem 'sinatra-contrib',  require: %w(sinatra/multi_route sinatra/reloader)
gem 'stripe'
gem 'sunlight'
gem 'thin'
gem 'unicorn'

group :test do
  gem 'factory_girl'
  gem 'rack-test',        require: 'rack/test'
  gem 'rspec'
  gem 'webmock', '1.6.2', require: false
end

group :development, :test do
  gem 'fakeredis'
  gem 'guard'
  gem 'guard-coffeescript'
  gem 'guard-jammit'
  gem 'guard-less'
  gem 'therubyracer'
end
