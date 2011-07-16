# TheRaceAppServer

The RaceApp Backend.

## Getting up and running

```
git clone git@github.com:Appsterdam/TheRaceApp.git
cd ./TheRaceAppServer
git checkout server

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
git push heroku server:master

heroku scale web=1
```
