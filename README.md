# hubot-google-calendar

hubot scripts for accesing google calendar

## configuration

hubot-google-calendar authorized by google service account. So check these steps for creating it.

* https://developers.google.com/accounts/docs/OAuth2ServiceAccount?hl=ja
* https://github.com/extrabacon/google-oauth-jwt#creating-a-service-account-using-the-google-developers-console

And service account is created, allow to access your google caelndar form service account.

## enviroment variable

* HUBOT_GOOGLE_CALENDAR_EMAIL
    * email of google service account
* HUBOT_GOOGLE_CALENDAR_KEYFILE
    * keyfile of google service account

## usage

### hubot calendar

show today events.

```
Hubot> Hubot: calendar
Hubot> name@example.com
2014-01-01 ~ 2014-01-02 foo
2014-01-01T00:00:00+09:00 ~ 2014-01-02T01:00:00+09:00 bar
```

### hubot calendar (today|tomorrow)

show today or tomorrow events.

```
Hubot> Hubot: calendar tomorrow
Hubot> name@example.com
2014-01-02 ~ 2014-01-03 foo
2014-01-02T00:00:00+09:00 ~ 2014-01-03T01:00:00+09:00 bar
```
