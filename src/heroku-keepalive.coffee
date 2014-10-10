# Description
#   A hubot script that keeps its Heroko web dynos alive
#
# Configuration:
#   HUBOT_HEROKU_KEEPALIVE_URL or HEROKU_URL: required
#   HUBOT_HEROKU_KEEPALIVE_INTERVAL: optional, defaults to 5 minutes
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Josh Nichols <technicalpickles@github.com>

module.exports = (robot) ->
  keepaliveUrl = process.env.HUBOT_HEROKU_KEEPALIVE_URL or process.env.HEROKU_URL
  keepaliveUrl = "#{keepaliveUrl}/" unless keepaliveUrl?.match(/\/$/)

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
      robot.http("#{keepaliveUrl}heroku/keepalive").post() (err, res, body) =>
        robot.logger.info "keepalive pong: #{res.statusCode} #{body}"
    , keepaliveInterval * 60 * 1000
  else
    robot.logger.info "hubot-heroku-keepalive is #{keepaliveInterval}, so not keeping alive"

  keepaliveCallback = (req, res) ->
    res.set 'Content-Type', 'text/plain'
    res.send 'OK'

  # keep this different from the legacy URL in httpd.coffee
  robot.router.post "/heroku/keepalive", keepaliveCallback
  robot.router.get "/heroku/keepalive", keepaliveCallback
