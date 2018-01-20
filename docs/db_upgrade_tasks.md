<do database backup from heroku ui>

heroku addons:create heroku-postgresql:premium-0 --app production-1
heroku pg:wait --app production-1

heroku maintenance:on --app production-1
heroku pg:copy DATABASE_URL HEROKU_POSTGRESQL_COBALT_URL --app production-1

heroku pg:promote HEROKU_POSTGRESQL_COBALT_URL --app production-1

git push heroku master
heroku maintenance:off --app production-1
