# postcongress

This is the code that powers [postcongres.io](http://postcongress.io).
## Installation

```bash
heroku create
heroku addons:add redistogo
heroku config:set STRIPE_API_KEY=yourkey
heroku config:set STRIPE_API_PUBLIC_KEY=yourpublickey
heroku config:set SHIP_API_KEY=yourshipkey
heroku config:set SUNLIGHT_LABS_API_KEY=sunlightlabskey
heroku config:set REDIS_URL=redistogourl
heroku config:set S3_BUCKET=bucketname
git push heroku master
```

## Development

```bash
bundle
bundle exec foreman start
```

Code away.
