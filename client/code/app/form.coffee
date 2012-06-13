Frame = require('/app').Frame

resize = -> $(window).trigger 'resize'
clear  = -> $(@).html ''

class FormFrame extends Frame
  rpc: 'formFrame'
  render: (forms)->
    at = $('.formpl_frame')
    at.html ''
    forms.each (template, values)->
      html = ss.tmpl[template].render values
      $(html).appendTo(at)
    at.hide().slideDown 'slow', resize

  data: ->
    formEntry: =>
      @click ':submit', =>
        face_id = @find('select').val()
        ss.rpc 'trpg.entryPotof', face_id, (success) => 
          if success
            @find().show().slideUp 'normal', clear
          else
            alert('Oops! Unable to send message')

      @change 'select', =>
        face_id = @find('select').val() || 'undef'
        imgPath = "#{URL.rails}/images/portrate/#{face_id}.jpg"
        @find('.img img').attr 'src', imgPath

    formActor: =>
      @click ':submit', =>
        false

      @change ':input', =>
        @find('.confirm').html 'changed!'

class InfoFrame extends Frame
  rpc: 'infoFrame'
  render: (message)->
    $(".caution").html message

exports.InfoFrame = new InfoFrame()
exports.FormFrame = new FormFrame()

