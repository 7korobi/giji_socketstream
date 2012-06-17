db = require 'mongoose'
ObjectId = db.Schema.ObjectId

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

FaceSchema = new db.Schema Face
FaceSchema.statics.findSelectOptions = (cb)->
  @where().asc('order').run (err,doc)->
    if doc
      group = doc.groupBy (o)->
        o.face_id.match(/[a-z]+/)[0]
      cb err, group
    else
      cb err, null

console.log exports.Face  = db.model 'faces', FaceSchema
console.log exports.User  = db.model 'users', UserSchema = new db.Schema User

