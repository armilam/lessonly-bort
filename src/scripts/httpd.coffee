# Description:
#   A simple interaction with the built in HTTP Daemon
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# URLS:
#   /hubot/version
#   /hubot/ping
#   /hubot/time
#   /hubot/info
#   /hubot/ip

spawn = require('child_process').spawn

module.exports = (robot) ->

  robot.router.get "/bort/image", (req, res) ->
    console.log "Request for image: #{req.query.q}"
    imageMe robot, req.query.q, (url) ->
      console.log "Got image: #{url}"
      robot.send res, url

  robot.router.get "/bort/gif", (req, res) ->
    console.log "Request for gif: #{req.query.q}"
    imageMe robot, req.query.q, true, (url) ->
      console.log "Got image: #{url}"
      robot.send res, url

  robot.router.get "/bort/version", (req, res) ->
    res.end robot.version

  robot.router.post "/bort/ping", (req, res) ->
    res.end "PONG"

  robot.router.get "/bort/time", (req, res) ->
    res.end "Server time is: #{new Date()}"

  robot.router.get "/bort/info", (req, res) ->
    child = spawn('/bin/sh', ['-c', "echo I\\'m $LOGNAME@$(hostname):$(pwd) \\($(git rev-parse HEAD)\\)"])

    child.stdout.on 'data', (data) ->
      res.end "#{data.toString().trim()} running node #{process.version} [pid: #{process.pid}]"
      child.stdin.end()

  robot.router.get "/bort/ip", (req, res) ->
    robot.http('http://ifconfig.me/ip').get() (err, r, body) ->
      res.end body

imageMe = (msg, query, animated, faces, cb) ->
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  q = v: '1.0', rsz: '8', q: query, safe: 'active'
  q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
  q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(q)
    .get() (err, res, body) ->
      images = JSON.parse(body)
      images = images.responseData?.results
      if images?.length > 0
        r = Math.floor(Math.random() * images.length)
        image = images[r]
        cb ensureImageExtension image.unescapedUrl

ensureImageExtension = (url) ->
  ext = url.split('.').pop()
  if /(png|jpe?g|gif)/i.test(ext)
    url
  else
    "#{url}#.png"