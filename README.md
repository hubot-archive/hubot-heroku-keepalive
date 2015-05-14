# hubot-heroku-keepalive

A hubot script that keeps the hubot Heroko web dyno alive.

## Installation

In hubot project repository, run:

`npm install hubot-heroku-keepalive --save`

Then add **hubot-heroku-keepalive** to your `external-scripts.json`:

```json
[
  "hubot-heroku-keepalive"
]
```

## Configuring

hubot-heroku-keepalive is configured by four environment variables:

* HUBOT_HEROKU_KEEPALIVE_URL - the URL to keepalive
* HUBOT_HEROKU_KEEPALIVE_INTERVAL - the interval in which to keepalive, in minutes
* HUBOT_HEROKU_WAKEUP_TIME - optional,  the time of day (HH:MM) when hubot should wake up.  Default 6:00 (6 am)
* HUBOT_HEROKU_SLEEP_TIME - optional, the time of day (HH:MM) when hubot should go to sleep. Default 22:00 (10 pm)

In May, 2015, Heroku introduced a [new pricing tier](https://blog.heroku.com/archives/2015/5/7/new-dyno-types-public-beta)
doing away with a 24/7 free dyno. `HUBOT_HEROKU_WAKEUP_TIME` and
`HUBOT_HEROKU_SLEEP_TIME` define the waking hours - between these times the keepalive
will ping your Heroku app.  Outside of those times, the ping will be surpressed
allowing the dyno to shut down.  Accessing your Hubot during a sleep period will
wake it, but it will return to sleep after 30 minutes.  `HUBOT_HEROKU_WAKEUP_TIME`
and `HUBOT_HEROKU_SLEEP_TIME` are times based on the timezone of your Heroku
application which defaults to UTC.  You can change this with
`heroku config:add TZ="America/New_York"`


For hubot-heroku-keepalive to be useful, you *must* at least set
HUBOT_HEROKU_KEEPALIVE_URL. You can find out the value for this by using the
[Heroku Toolbelt](https://toolbelt.heroku.com/):

```
heroku apps:info
```

Copy the `Web URL`, and then `config:set` HUBOT_HEROKU_KEEPALIVE_URL:

```
heroku config:set HUBOT_HEROKU_KEEPALIVE_URL=PASTE_WEB_URL_HERE
```

If you want to trust a shell snippet from the Internet, here's a one-liner:

```
heroku config:set HUBOT_HEROKU_KEEPALIVE_URL=$(heroku apps:info -s  | grep web_url | cut -d= -f2)
```

## Legacy Support

Hubot has for a long time had it's own builtin way to keep its web dyno alive,
but this is an extraction of that behavior.

The legacy support uses the `HEROKU_URL` environment variable instead of
`HUBOT_HEROKU_KEEPALIVE_URL`, so for forward compatability,
hubot-heroku-keepalive will also use HEROKU_URL if it's present, and will
also disable the legacy keepalive behavior if it's present.

## Development

The best way is to use `npm link` and make sure to point HUBOT_HEROKU_KEEPALIVE_URL at the right place:

```
hubot-heroku-keepalive$ npm link
hubot-heroku-keepalive$ cd /path/to/your/hubot
hubot$ npm link hubot-heroku-keepalive
hubot$ export HUBOT_HEROKU_KEEPALIVE_URL=http://localhost:8080/
hubot$ bin/hubot
