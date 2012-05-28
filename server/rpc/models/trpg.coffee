db = require 'mongoose'

Schema   = db.Schema
ObjectId = db.Schema.ObjectId

Message = new Schema
  _id:   String
  logid: String
  subid: String

  color:   String
  style:   String
  mestype: String

  potof_id: ObjectId
  face_id:  String
  name: String
  csid: String
  to:   String
  log:  String

TrpgEvent = new Schema
  _id:      String
  story_id: String
  turn:     Number
  _type:    {type: String, default: 'TrpgEvent' }

  messages: [Message]
  name:   String
  state:  String
  closed_at:  Date
  created_at: {type: Date,   default: Date.now}

TrpgStory = new Schema
  _id:    String
  folder: String
  vid:    Number
  _type:  {type: String, default: 'TrpgStory' }

  name:    String
  comment: String
  rating:  String
  is_finish: Boolean
  created_at: {type: Date,   default: Date.now}



TrpgPotof  = new Schema
  _id:    ObjectId
  _type:  {type: String, default: 'TrpgPotof' }

  user_id:  String
  face_id:  String
  name:     String
  event_id: String
  story_id: String


Face  = new Schema
  _id:   String
  face_id: String
  name:    String
  comment: String
  order:   String

User = new Schema
  _id:     String
  user_id: String
  name:  String
  email: String
  rails_token: String


db.model 'stories', TrpgStory
db.model 'events',  TrpgEvent
db.model 'potofs',  TrpgPotof
db.model 'faces',   Face
db.model 'users',   User
db.connect "mongodb://7korobi:kotatsu3@utage.sytes.net/giji"

module.exports.TrpgStory = db.model 'stories'
module.exports.TrpgEvent = db.model 'events'
module.exports.TrpgPotof = db.model 'potofs'
module.exports.Face  = db.model 'faces'
module.exports.User  = db.model 'users'
