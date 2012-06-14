resize = -> $(window).trigger 'resize'
clear  = -> $(@).html ''
render = (forms)->
  at = $('.formpl_frame')
  at.html ''
  forms.each (template, values)->
    html = ss.tmpl[template].render values
    $(html).appendTo(at)
  at.hide().slideDown 'slow', resize

Frame = require('/app').Frame

Frame.each exports,
  formEntry: ->
    @event 'formFrame', render
    @click ':submit', =>
      face_id = @find('#face').val()
      prefix = @find('#prefix').val()
      name  = @find("[value=#{face_id}]").text()
      ss.rpc 'trpg.entryPotof', face_id, prefix, name, (success) => 
        if success
          @find().show().slideUp 'normal', clear
        else
          alert('Oops! Unable to send message')

    @change '#face', =>
      face_id = @find('#face').val() || 'undef'
      imgPath = "#{URL.rails}/images/portrate/#{face_id}.jpg"
      @find('.img img').attr 'src', imgPath

  formActor: ->
    @event 'formFrame', render
    @click ':submit', =>
      false

    @change ':input', =>
      @find('.confirm').html 'changed!'

exports.InfoFrame = new Frame
exports.InfoFrame.event 'infoFrame', (message)->
  $(".caution").html message

