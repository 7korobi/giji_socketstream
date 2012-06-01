ss = require 'socketstream'
db = require 'mongoose'

db.connect "mongodb://7korobi:kotatsu3@utage.sytes.net/giji"

redis_db = 
  host: 'utage.sytes.net'
  port: 6379
  db:   3
ss.session.store.use     "redis", redis_db
ss.publish.transport.use 'redis', redis_db





