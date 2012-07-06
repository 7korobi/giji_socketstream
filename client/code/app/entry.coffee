# This file automatically gets called first by SocketStream and must always exist
# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')


app = angular.module '', []
app.config ($interpolateProvider)->

window.templates = {}

window.HEAD = ($scope)->
  head = $scope

  window.MAIN = ($scope, $interpolate)->
    $("script[type='text/x-tmpl']").each (idx, val)->
      return unless 'tmpl-giji-info' == val.id || 'tmpl-giji-say' == val.id
      html = $(val).html()
      templates[val.id] = $interpolate(html)

    main = head.main = $scope
    main.title = 'test'
    main.message = 'test'
    main.logs = [
      template: 'tmpl-giji-info'
      mestype: 'INFONOM'
      text: 'ログ表示テスト'
    ,
      template: 'tmpl-giji-say'
      mestype: 'SAY'
      text: "ログ表示テスト<br>テスト"
      style: 'head'
      name: 'まご マーゴ'
      face_id: 'c79'
      logid: 'SS00000'
      time: new Date()
    ,
      template: 'tmpl-giji-info'
      mestype: 'INFOSP'
      text: 'ログ表示テスト'
    ]
    main.message = (log)->
      templates[log.template](log)

  window.TAB = ($scope)->
    tab = head.tab = $scope
    ss.server.on 'disconnect', ->
      head.main.title = 'Connection down :-('
      tab.$apply()

    ss.server.on 'reconnect', ->
      head.main.title = 'Connection back up :-)'
      tab.$apply()

  window.CSS = ($scope)->
    css = head.css = $scope
    css.click = (theme, width)->
      date    = new Date
      current = "#{theme}#{width}"
      css.href = "#{URL.rails}stylesheets/#{current}.css"
      css.width = width
      css.name = {}
      css.name[current] = "btn-success"
      css.h1 = 
        type: OPTION.head_img[current][ Math.ceil((date).getTime() / 60*60*12) % 2]
      switch width
        when 480
          css.h1.width = 458
        when 800
          css.h1.width = 580
    css.click 'wa', 800


ss.server.on 'ready', ->
  params = location.pathname.match ///
    trpg/([a-z]*-.-.)/(.*)
  ///

  jQuery ->
    angular.bootstrap(document);
    require('/app')
    require('/form')
    
    ss.rpc 'trpg.initialize', params.pop(), params.pop()
