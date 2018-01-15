heroku addons:create heroku-postgresql:premium-0 --app production-1
heroku pg:wait --app production-1

heroku maintenance:on --app production-1
heroku pg:copy DATABASE_URL CREATED_DATABASE_URL --app production-1

heroku pg:promote CREATED_DATABASE_URL --app production-1

heroku maintenance:off --app production-1



1. 1-2
2. 5
3. deprovision new db
