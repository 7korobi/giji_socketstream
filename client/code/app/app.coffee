
class Frame
  event: (rpc, render)->
    ss.event.on rpc, render
  find: (path)-> $("#{@baseId} #{path}")

[ 'click'
  'change'
].each (event)->
  Frame.prototype[event] = (path, act)->
    $(document).on event,  "#{@baseId} #{path}", act

Frame.each = (obj, data)->
  data?.each (template, cb)->
    frame = new Frame
    frame.baseId = "#" + template.dasherize() if template
    frame.initialize = cb
    frame.initialize()
    obj[template] = frame
exports.Frame = Frame

exports.TitleFrame = new Frame
exports.TitleFrame.event 'titleFrame', (title)->
  $("#log-name").text(title)

exports.LogFrame = new Frame
exports.LogFrame.event 'logFrame', (log)->
  console.log log
  frame = $(".messages")
  log.each (item)->
    1

render = (forms)->
  at = $('.formpl_frame')
  at.html ''
  forms.each (template, values)->
    html = ss.tmpl[template].render values
    $(html).attr('id', template).appendTo(at)
  at.hide().slideDown 'slow', resize


ss.event.on 'newMessage', (message) ->
  html = ss.tmpl['giji-info'].render
    color: 'INFONOM', 
    text:   message,
    time: -> timestamp() 
  insert(html, '.messages')


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
    ss.rpc('trpg.sendMessage', text, cb)
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