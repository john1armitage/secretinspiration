jQuery ->
  Account =
    checkQuick: (quick) ->
      if quick
        $('div.row.quick').show()
        $('div.row.line-items').hide()
      else
        $('div.row.quick').hide()
        $('div.row.line-items').show()
  Utility =
    menuSelect: ->
      $('div#menu li').on 'click', (event) ->
        $('div#menu li').removeClass 'active'
        $(this).addClass('active')

  Ajaxify.init
    content_container: 'content'
