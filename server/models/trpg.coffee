db = require 'mongoose'
ObjectId = db.Schema.ObjectId

idString =
  type: String
  trim: true
  lowercase: true
  match: /[---0-9a-z]+/


Chat = 
  _id:   idString
  logid: String
  style: String

  potof_id: ObjectId
  to:   String
  log:  String


Message = Chat.merge
  subid: String

  color:   idString
  mestype: String

  face_id: idString
  name: String
  csid:    idString

TrpgEvent = 
  _id:      idString
  story_id: idString
  turn:     Number
  _type:    {type: String, default: 'TrpgEvent' }

  messages: [Message]
  name:   String
  state:  String
  closed_at:  Date
  created_at: {type: Date,   default: Date.now}

TrpgStory = 
  _id:    idString
  folder: idString
  vid:    Number
  _type:  {type: String, default: 'TrpgStory' }

  name:    String
  comment: String
  rating:  String
  is_finish: Boolean
  created_at: {type: Date,   default: Date.now}

TrpgPotof = 
  _id:    ObjectId
  _type:  {type: String, default: 'TrpgPotof' }

  user_id:  idString
  face_id:  idString
  fullname: String
  name:     String
  event_id: idString
  story_id: idString

EventSchema = new db.Schema TrpgEvent
EventSchema.methods.is_open = ->  0 == @turn && 'OPEN' == @state

StorySchema = new db.Schema TrpgStory
StorySchema.methods.is_open = ->  ! @is_finish

console.log exports.Story = db.model 'stories', StorySchema
console.log exports.Event = db.model 'events',  EventSchema
console.log exports.Potof = db.model 'potofs',  new db.Schema TrpgPotof
