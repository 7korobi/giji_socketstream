# This file automatically gets called first by SocketStream and must always exist
# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')

window.templates = {}
window.HEAD = ($scope)->

  ss.server.on 'disconnect', ->
    head.main.title = 'Connection down :-('
    head.$apply()

  ss.server.on 'reconnect', ->
    head.main.title = 'Connection back up :-)'
    head.$apply()

  [_, event_id, rails_token] = location.pathname.match ///
    trpg/([a-z]*-.-.)/(.*)
  ///
  ss.rpc 'trpg.initialize', rails_token, event_id

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
      time: new Date()
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
      time: new Date()
    ]
    main.message = (log)->
      templates[log.template](log)

  window.TAB = ($scope)->
    tab = head.tab = $scope
    tab.move = (target)=>
      @params.change(target)
      tab.info = tab.link = tab.calc = null
      tab[target] = 'btn-success'
      tab.item = target
    @params = new Params('tab')
    @params.merge
      current: 'link'
      is_cookie: false
      on: 'hash'
    if "onhashchange" of window and (document.documentMode is `undefined` or document.documentMode > 7)
      window.onhashchange = =>
        tab.move @params.val()
    tab.move @params.val()

  window.PAGER = ($scope)->
    pager = head.pager = $scope
    pager.length = 100
    pager.move = (page)=>
      @params.change(page)

      @style_on  = 'btn btn-success'
      @style_off = 'btn'

      @first =    1
      @second =   2
      @prev =     page - 1 
      @current =  page
      @next =     page + 1
      @penu =     pager.length  - 1
      @last =     pager.length

      @show =
        first:    0 < @last
        second:   1 < @last
        last:     2 < @last
        penu:     2 < @penu
        prev_gap: 2 < @prev - 1 < @penu
        prev:     2 < @prev     < @penu
        current:  2 < @current  < @penu
        next:     2 < @next     < @penu
        next_gap: 2 < @next + 1 < @penu
      for key, val of @show
        @show[key] and= if page == @[key] then @style_on else @style_off 
      pager.merge @
      location.hash
    @params = new Params('page')
    @params.merge
      current: '1'
      is_cookie: false
      on: 'hash'
    if "onhashchange" of window and (document.documentMode is `undefined` or document.documentMode > 7)
      window.onhashchange = =>
        pager.move @params.val().toNumber()
    pager.move @params.val().toNumber()

  window.CSS = ($scope)->
    css = head.css = $scope
    css.move = (target)=>
      @params.change(target)
      [_, theme, width] = target.match /([a-z]*)([0-9]*)/
      width = width.toNumber()

      date    = new Date
      current = "#{theme}#{width}"
      css.merge
        href: "#{URL.rails}stylesheets/#{current}.css"
        width: width
        name:  {}

      css.name[current] = "btn-success"
      css.h1 = 
        type: OPTION.head_img[current][ Math.ceil((date).getTime() / 60*60*12) % 2]
      switch width
        when 480
          css.h1.width = 458
        when 800
          css.h1.width = 580
    @params = new Params('css')
    @params.merge
      current: 'wa800'
      is_cookie: true
      on: 'hash'
    if "onhashchange" of window and (document.documentMode is `undefined` or document.documentMode > 7)
      window.onhashchange = =>
        css.move @params.val()
    css.move @params.val()

  console.log head

ss.server.on 'ready', ->
  jQuery ->
    require('/app')
    require('/form')

    app = angular.module '', []
    app.config ($interpolateProvider)->
    angular.bootstrap(document);

    