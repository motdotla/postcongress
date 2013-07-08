class Application < Sinatra::Base
  set :haml, format: :html5
  register Sinatra::Reloader

  helpers do
    def jsonify(*args)
      render(:jsonify, *args)
    end
  end
 
  get "/" do
    @s3_bucket = S3_BUCKET
    @bg_number = rand(5)
    haml :index
  end
end
