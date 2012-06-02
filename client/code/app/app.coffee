ss.event.on 'infoFrame', (message)->
  $(".caution").html message


ss.event.on 'formFrame', (forms)->
  resize = ->
    resize = -> 0
    $(window).trigger 'resize'

  $('.formpl_frame').html ''
  forms.each (template, values)->
    html = ss.tmpl[template].render values
    $(html).hide().appendTo('.formpl_frame').slideDown 'slow', resize


ss.event.on 'newMessage', (message) ->
  html = ss.tmpl['giji-info'].render
    color: 'INFONOM', 
    text:   message,
    time: -> timestamp() 
  insert(html, '.messages')



$(document).on 'click',  '#form-entry :submit', ->
  false

$(document).on 'change', '#form-entry select', ->
  id = $(@).val();
  $('#form-entry .img img').attr('src', "#{URL.rails}/images/portrate/#{id}.jpg")


$(document).on 'click', '#form-actor :submit', ->
  false

$(document).on 'change', '#form-actor :input', ->
  $('#form-actor .confirm').html 'changed!'


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