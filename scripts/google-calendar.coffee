# Description:
#   google calendar for hubot
# Commands:
#   hubot calendar - list up today event
#   hubot calendar (today|tomorrow) - list up today or tomorrow event

requestWithJWT = require('google-oauth-jwt').requestWithJWT()
moment         = require('moment-timezone')
_              = require('underscore')

module.exports = (robot) ->

  robot.respond /calendar$/i, (msg) ->
    try
      getCalendarEvents new Date(), (str) ->
        msg.send str
    catch e
      msg.send "exception: #{e}"

  robot.respond /calendar (today|tomorrow)$/i, (msg) ->
    switch msg.match[1]
      when "today"
        try
          getCalendarEvents new Date(), (str) ->
            msg.send str
        catch e
          msg.send "exception: #{e}"
      when "tomorrow"
        d = new Date()
        d.setDate(d.getDate() + 1)
        try
          getCalendarEvents d, (str) ->
            msg.send str
        catch e
          msg.send "exception: #{e}"

  request = (opt, onSuccess, onError) ->
    params =
      jwt:
        email: process.env.HUBOT_GOOGLE_CALENDAR_EMAIL
        keyFile: process.env.HUBOT_GOOGLE_CALENDAR_KEYFILE
        scopes: ['https://www.googleapis.com/auth/calendar.readonly']

    _.extend(params, opt)

    robot.logger.debug(params)

    requestWithJWT(params, (err, res, body) ->
      if err
        onError(err)
      else
        if res.statusCode != 200
          onError "status code is #{res.statusCode}"
          return

        onSuccess JSON.parse(body)
    )

  formatEvent = (event) ->
    strs = []
    if event.start
      if event.start.date
        strs.push event.start.date
      else if event.start.dateTime
        strs.push event.start.dateTime

    if event.end
      strs.push "~"
      if event.end.date
        strs.push event.end.date
      else if event.end.dateTime
        strs.push event.end.dateTime

    strs.push event.summary
    strs.join " "

  getCalendarEvents = (baseDate, cb) ->
    onError = (err) ->
      cb "receive err: #{err}"

    request(
      { url: 'https://www.googleapis.com/calendar/v3/users/me/calendarList' }
      (data) ->
        timeMin = new Date(baseDate.getTime())
        timeMin.setHours 0, 0, 0
        timeMax = new Date(baseDate.getTime())
        timeMax.setHours 23, 59, 59
        for i, item of data.items
          do (item) ->
            request(
              {
                url: "https://www.googleapis.com/calendar/v3/calendars/#{item.id}/events"
                qs:
                  timeMin: moment(timeMin).tz(item.timeZone).format()
                  timeMax: moment(timeMax).tz(item.timeZone).format()
                  orderBy: 'startTime'
                  singleEvents: true
                  timeZone: item.timeZone
              }
              (data) ->
                strs = [item.id]
                for i, item of data.items
                  # for all day event.
                  # for example, end date of 1/1 is 1/2. so i want only 1/2 event, but also get 1/1 event.
                  if item.end.date
                    d = new Date(item.end.date)
                    d.setHours 0, 0, 0
                    if d < timeMin
                      continue
                  strs.push formatEvent(item)
                cb strs.join("\n")
              onError
            )
      onError
    )
