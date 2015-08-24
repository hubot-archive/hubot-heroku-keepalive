# Description
#   A hubot script that keeps its Heroko web dynos alive.
#
# Notes:
#   This replaces hubot's builtin Heroku keepalive behavior. It uses the same
#   environment variable (HEROKU_URL), but removes the period ping.  Pings will
#   only occur between the WAKEUP_TIME and SLEEP_TIME in the timezone your
#   heroku instance is running in (UTC by default).
#
# Configuration:
#   HUBOT_HEROKU_KEEPALIVE_URL or HEROKU_URL: required
#   HUBOT_HEROKU_KEEPALIVE_INTERVAL: optional, defaults to 5 minutes
#   HUBOT_HEROKU_WAKEUP_TIME: optional, defaults to 6:00 (6 AM).
#   HUBOT_HEROKU_SLEEP_TIME: optional, defaults to 22:00 (10 PM)
#
#   heroku config:add TZ="America/New_York"
#
# URLs:
#   POST /heroku/keepalive
#   GET /heroku/keepalive
#
# Author:
#   Josh Nichols <technicalpickles@github.com>

module.exports = (robot) ->
  wakeUpTime = (process.env.HUBOT_HEROKU_WAKEUP_TIME or '6:00').split(':')
  sleepTime = (process.env.HUBOT_HEROKU_SLEEP_TIME or '22:00').split(':')

  wakeUpOffset = 60 * wakeUpTime[0]  + 1 * wakeUpTime[1]
  sleepOffset  = 60 * sleepTime[0]   + 1 * sleepTime[1]

  keepaliveUrl = process.env.HUBOT_HEROKU_KEEPALIVE_URL or process.env.HEROKU_URL
  if keepaliveUrl and not keepaliveUrl.match(/\/$/)
    keepaliveUrl = "#{keepaliveUrl}/"

  # interval, in minutes
  keepaliveInterval = if process.env.HUBOT_HEROKU_KEEPALIVE_INTERVAL?
                        parseFloat process.env.HUBOT_HEROKU_KEEPALIVE_INTERVAL
                      else
                        5

  unless keepaliveUrl?
    robot.logger.error "hubot-heroku-alive included, but missing HUBOT_HEROKU_KEEPALIVE_URL. `heroku config:set HUBOT_HEROKU_KEEPALIVE_URL=$(heroku apps:info -s  | grep web_url | cut -d= -f2)`"
    return

  # check for legacy heroku keepalive from robot.coffee, and remove it
  if robot.pingIntervalId
    clearInterval(robot.pingIntervalId)

  if keepaliveInterval > 0.0
    robot.herokuKeepaliveIntervalId = setInterval =>
      robot.logger.info 'keepalive ping'

      now = new Date()
      nowOffset    = 60 * now.getHours() + now.getMinutes()

      if (nowOffset >= wakeUpOffset && nowOffset < sleepOffset)
        robot.http("#{keepaliveUrl}heroku/keepalive").post() (err, res, body) =>
          if err?
            robot.logger.info "keepalive pong: #{err}"
            robot.emit 'error', err
          else
            robot.logger.info "keepalive pong: #{res.statusCode} #{body}"
      else
        robot.logger.info "Skipping keep alive, time to rest"

    , keepaliveInterval * 60 * 1000
  else
    robot.logger.info "hubot-heroku-keepalive is #{keepaliveInterval}, so not keeping alive"

  keepaliveCallback = (req, res) ->
    res.set 'Content-Type', 'text/plain'
    res.send 'OK'

  # keep this different from the legacy URL in httpd.coffee
  robot.router.post "/heroku/keepalive", keepaliveCallback
  robot.router.get "/heroku/keepalive", keepaliveCallback
