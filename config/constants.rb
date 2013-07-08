RACK_ENV                  = ENV['RACK_ENV']
APP_NAME                  = "postcongress"
ROOT_DOMAIN               = "dev:5000"
REDIS_URL                 = ENV['REDIS_URL']
STRIPE_API_KEY            = ENV['STRIPE_API_KEY'] 
STRIPE_PUBLIC_KEY         = ENV['STRIPE_PUBLIC_KEY']
AMOUNT_IN_CENTS           = 199
CURRENCY                  = "usd"
SHIP_API_KEY              = ENV['SHIP_API_KEY']
FRONT_PHOTO_ID            = "10850777"
FRONT_PHOTO_IDS           = ["10946625", "10946635", "10946638", "10946639", "10946640"]
SUNLIGHT_LABS_API_KEY     = ENV['SUNLIGHT_LABS_API_KEY'] 
S3_BUCKET                 = ENV['S3_BUCKET']

case RACK_ENV
when "production"
  ROOT_DOMAIN             = "postcongress.io"
else  
  # defined above 
end
