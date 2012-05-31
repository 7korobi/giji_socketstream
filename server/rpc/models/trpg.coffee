db = require 'mongoose'
ObjectId = db.Schema.ObjectId

Chat = 
  _id:   String
  logid: String

  style:   String

  potof_id: ObjectId
  to:   String
  log:  String


Message = Chat.merge
  subid: String

  color:   String
  mestype: String

  face_id:  String
  name: String
  csid: String

TrpgEvent = 
  _id:      String
  story_id: String
  turn:     Number
  _type:    {type: String, default: 'TrpgEvent' }

  messages: [Message]
  name:   String
  state:  String
  closed_at:  Date
  created_at: {type: Date,   default: Date.now}

TrpgStory = 
  _id:    String
  folder: String
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

  user_id:  String
  face_id:  String
  name:     String
  event_id: String
  story_id: String


Face = 
  _id:   String
  face_id: String
  name:    String
  comment: String
  order:   String

User = 
  _id:     String
  user_id: String
  name:  String
  email: String
  rails_token: String

console.log exports.TrpgStory = db.model 'stories', new db.Schema TrpgStory
console.log exports.TrpgEvent = db.model 'events',  new db.Schema TrpgEvent
console.log exports.TrpgPotof = db.model 'potofs',  new db.Schema TrpgPotof
console.log exports.Face  = db.model 'faces',   new db.Schema Face
console.log exports.User  = db.model 'users',   new db.Schema User
