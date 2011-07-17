# TheRaceAppServer

The RaceApp Backend.

## Getting up and running

```
git clone git@github.com:Appsterdam/TheRaceApp.git
cd ./TheRaceAppServer
git checkout server

export GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY

bundle install
rake dm:auto:migrate
padrino start
```

## Deploy to Heroku

```
cd ./TheRaceAppServer
git checkout server

gem install heroku

heroku create --stack cedar
heroku addons:add shared-database
heroku config:add GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY

git push heroku server:master

heroku run rake dm:auto:migrate

heroku scale web=1
```
