Robot                                                = require '../robot'
Adapter                                              = require '../adapter'
User                                                 = require '../user'
{TextMessage,EnterMessage,LeaveMessage,TopicMessage} = require '../message'
Express = require('express')

class Rest extends Adapter
    send: (res, strings...) ->
        console.log "sending image back now"
        res.send strings[0]

    run: ->
        self = @
        self.emit 'connected'

exports.use = (robot) ->
  new Rest robot
