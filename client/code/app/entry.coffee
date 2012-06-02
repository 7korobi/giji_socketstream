# This file automatically gets called first by SocketStream and must always exist

# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')

ss.server.on 'disconnect', ->
  console.log('Connection down :-(')

ss.server.on 'reconnect', ->
  console.log('Connection back up :-)')

ss.server.on 'ready', ->
  params = location.href.match ///
    trpg/([a-z]*-.-.)/(.*)
  ///

  # Wait for the DOM to finish loading
  jQuery ->
    require('/app')
    
    Client.css.location = "http://giji.sytes.net/stylesheets/"
    Client.css.reload()

    ss.rpc 'trpg.initialize',
      rails_token: params.pop()
      event_id:    params.pop()
