# Server-side Code
# Define actions which can be called from the client using ss.rpc('demo.ACTIONNAME', param1, param2...)
# Example of pre-loading sessions into req.session using internal middleware
# Uncomment line below to use the middleware defined in server/middleware/example

require '../config.coffee'

giji = require '../models/giji.coffee'
trpg = require '../models/trpg.coffee'
exports.story = {}
exports.event = {}
exports.stat  = {}


class Stat
  initialize: (rails_token, cb)->

    key = rails_token: rails_token
    giji.User.findOne key, (err, doc)=>
      if doc
        @is_admin = doc.is_admin
        @user_id  = doc._id
        cb(doc)
      else
        @error('User', rails_token, err)

  fetch: (type, key, ok)->
    doc = exports[type][key] 
    if doc
      @[type] = doc
      @["#{type}_id"] = doc._id
      ok(doc)
    else
      trpg[type.camelize()].findById key, (err, doc)=>
        if doc
          exports[type][key] = doc
          @[type] = doc
          @["#{type}_id"] = doc._id
          ok(doc)
        else
          @error(type, key, err)

  near_potof: (cb)->
    trpg.Potof.findOne  story_id: @story_id, user_id: @user_id, (err, potof)=>
      console.log [@story_id, @user_id, potof]
      @potof = potof if potof
      cb(err, potof)

  new_potof: ->
    @potof = new trpg.Potof 
      user_id:  @user_id
      event_id: @event_id
      story_id: @story_id

  is_author: -> false
  is_actor: -> @user_id? && ! @story.is_finish
  is_here: -> @event_id == @potof.event_id

  enable_entry:  -> @enable_open() && 0 == @event.turn
  enable_open:   -> @is_actor()  && 'OPEN' == @event.state 
  enable_invite: -> @is_author() && ('OPEN' == @event.state || 'INVITE' == @event.state)
  enable_secret: -> @is_actor()  && 'SECRET' == @event.state 

Stat.memory = (id)->
  exports.stat[id] = exports.stat[id] || new Stat()


exports.actions = (req, res, ss) ->
  req.use 'session'

  info = (data)-> 
    ss.publish.socketId req.socketId, 'infoFrame', data
    console.log data
  form = (data)-> ss.publish.socketId req.socketId, 'formFrame', data
  log  = (data)-> ss.publish.socketId req.socketId,  'logFrame', data
  pub  = (data)-> ss.publish

  stat = Stat.memory(req.sessionId)
  console.log.delay 1000, req
  console.log.delay 2000, stat

  abort_potof = (err)->
    info "更新できませんでした。" if err?

  initialize: (rails_token, event_id)->
    stat.error = (type, key, err)->
      info "missing #{type}."
    stat.initialize rails_token, (user)->
      req.session.setUserId(user._id)
      info "ルールを良く理解した上でご参加ください。"

    stat.fetch 'event', event_id, (event)->
      stat.fetch 'story', event.story_id, (story)->
        req.session.channel.subscribe event._id
        req.session.save()
        pub

        switch event.state
          when 'OPEN'
            stat.near_potof (err, potof)->
              if potof
                form 'form-bye':
                  face_id:  potof.face_id
                  fullname: potof.fullname
              else
                giji.Face.findSelectOptions (err,doc)-> 
                  form
                    'form-entry':
                      faces: doc
          else
            info "このイベントには参加できません。"

  entryPotof: (face_id, prefix, name)->
    return info "選択が無効です。"         unless face_id && ! face_id.isBlank()
    return info "肩書きが無効です。"       unless prefix  && ! prefix.isBlank()
    return info "選択が無効です。"         unless name    && ! name.isBlank()
    return info "イベントが開いていません。" unless stat.enable_open()

    stat.near_potof (err, potof)->
      if potof
        potof.event_id = stat.event_id
      else
        potof = stat.new_potof(face_id, prefix, name)
      potof.face_id = face_id
      potof.fullname = "#{prefix} #{name}"
      potof.name = name
      potof.save abort_potof

      form.delay 500
        'form-join':
          face_id: potof.face_id
          fullname: potof.fullname
      
  joinPotof: ->
    stat.near_potof (err, potof)->
      if potof
        potof.event_id = stat.event_id
        potof.save abort_potof
        form
          'form-actor':
            face_id:  potof.face_id
            fullname: potof.fullname

  byePotof: ->
    stat.near_potof (err, potof)->
      if potof
        stat.potof = null
        potof.remove()
        potof.save abort_potof

    switch stat.event.state
      when 'OPEN'
        giji.Face.findSelectOptions (err,doc)-> 
          form
            'form-entry':
              faces: doc

  sayMessage: ->
