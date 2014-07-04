requestWithJWT = (require 'google-oauth-jwt').requestWithJWT()
_              = require 'underscore'

request = (opt, onSuccess, onError) ->
  params =
    jwt:
      email: process.env.HUBOT_GOOGLE_CALENDAR_EMAIL
      keyFile: process.env.HUBOT_GOOGLE_CALENDAR_KEYFILE
      scopes: ['https://www.googleapis.com/auth/calendar.readonly']
  _.extend(params, opt)
  console.log(params)
  requestWithJWT(params, (err, res, body) ->
    if err
      onError(err)
    else
      if res.statusCode != 200
        console.log(res)
        return

      try
        data = JSON.parse(body)
        onSuccess(data)
      catch e
        console.log("failed to parse json")
        console.log(body)
        onError(e)
  )

formatEvent = (event) ->
  str = ""
  if event.start
    if event.start.date
      str += event.start.date
    else if event.start.dateTime
      str += event.start.dateTime

  if event.end
    str += " ~ "
    if event.end.date
      str += event.end.date
    else if event.end.dateTime
      str += event.end.dateTime

  str += " #{event.summary}"

module.exports = (robot) ->

  robot.respond /events/, (msg) ->
    onError = (err) ->
      console.log(err)
      msg.send "receive err #{err}"

    request(
      { url: 'https://www.googleapis.com/calendar/v3/users/me/calendarList' }
      (data) ->
        timeMin = new Date()
        timeMin.setHours(0, 0, 0)
        timeMax = new Date()
        timeMax.setHours(23, 59, 59)
        for i, item of data.items
          do (item) ->
            request(
              {
                url: "https://www.googleapis.com/calendar/v3/calendars/#{item.id}/events"
                qs:
                  timeMin: timeMin.toISOString()
                  timeMax: timeMax.toISOString()
                  orderBy: 'startTime'
                  singleEvents: true
              }
              (data) ->
                strs = [item.id]
                for i, item of data.items
                  strs.push(formatEvent(item))
                msg.send strs.join("\n")
              onError
            )
      onError
    )
