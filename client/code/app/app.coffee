### QUICK CHAT DEMO ####

Client.css.location = "http://giji.sytes.net/stylesheets/"
$ ->
  Client.css.reload()

  params = location.href.match ///
    (trpg-.-.)/(.*)
  ///
  ss.rpc 'demo.initialize',
    rails_token: params.pop()
    event_id:    params.pop()


ss.event.on 'newMessage', (message) ->

  html = ss.tmpl['giji-info'].render
    color: 'INFONOM', 
    text:   message,
    time: -> timestamp() 

  # Append it to the #chatlog div and show effect
  $(html).hide().appendTo('#chatlog').slideDown "fast", ->
    $(window).trigger 'resize'

# Show the chat form and bind to the submit action
$('#demo').on 'submit', ->

  # Grab the message from the text box
  text = $('#myMessage').val()

  exports.send text, (success) ->
    if success
      $('#myMessage').val('') # clear text box
    else
      alert('Oops! Unable to send message')


# Demonstrates sharing code between modules by exporting function
exports.send = (text, cb) ->
  if valid(text)
    ss.rpc('demo.sendMessage', text, cb)
  else
    cb(false)


# Private functions

timestamp = ->
  d = new Date()
  d.getHours() + ':' + pad2(d.getMinutes()) + ':' + pad2(d.getSeconds())

pad2 = (number) ->
  (if number < 10 then '0' else '') + number

valid = (text) ->
  text && text.length > 0