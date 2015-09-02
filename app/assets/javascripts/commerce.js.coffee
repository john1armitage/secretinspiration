jQuery ->
  Ajaxify.init
    content_container: 'content'
  Account =
    checkQuick: (quick) ->
      if quick
        $('div.row.quick').show()
        $('div.row.line-items').hide()
      else
        $('div.row.quick').hide()
        $('div.row.line-items').show()
  Utility =
    dismissConfirm: ->
      $('#cboxOverlay,#cboxOverlay,#confirmOverlay').remove()
    menuSelect: ->
      $('div#menu li').on 'click', (event) ->
        $('div#menu li').removeClass 'active'
        $(this).addClass('active')
  $('ul.dropdown li:not(.title),li.level-one').on 'click', (event) ->
    $('li.menu-icon').click()
    $('div#editor').html('')
  $(document).on "click", 'input[value="Cancel"]', (event) ->
    event.preventDefault()
    $(this).parents().find('div#editor').html('')
  $(document).on "click", 'a#print', (event) ->
    $('.no-print').hide()
    window.print()
    $('.no-print').show()
    event.preventDefault()
  $(document).on "click", 'a.no_content', (event) ->
    $('div#content').html('')
  $(document).on "click", 'input#bill_check', (event) ->
    voucher = parseFloat($('input#order_voucher').val())
    cheque = parseFloat($('input#order_cheque').val())
    cash = parseFloat($('input#order_cash').val())
    credit_card = parseFloat($('input#order_credit_card').val())
    goods = parseFloat($('input#order_goods').val())
    bill = parseFloat($('input#order_total').val())
    total_paid = credit_card + cash + cheque
    total_due = bill + goods - voucher
    net_tips = total_paid - total_due
    if net_tips < 0
      net_tips = 0.00
    $('span#paid').text('£' + parseFloat(total_paid, 10).toFixed(2))
    $('span#due').text('£' + parseFloat(total_due, 10).toFixed(2))
    $('span#tip').text('£' + parseFloat(net_tips, 10).toFixed(2))
    $('input#order_tip').val(net_tips)
    $('input#order_paid').val(total_paid)
    event.preventDefault()
  $(document).on "click", 'input#bill_payment', (event) ->
    voucher = parseFloat($('input#order_voucher').val())
    cheque = parseFloat($('input#order_cheque').val())
    cash = parseFloat($('input#order_cash').val())
    credit_card = parseFloat($('input#order_credit_card').val())
    goods = parseFloat($('input#order_goods').val())
    bill = parseFloat($('input#order_total').val())
    total_paid = credit_card + cash + cheque
    total_due = bill + goods - voucher
    net_tips = total_paid - total_due
    if net_tips < 0
      net_tips = 0.00
    $('span#paid').text('£' + parseFloat(total_paid, 10).toFixed(2))
    $('span#due').text('£' + parseFloat(total_due, 10).toFixed(2))
    $('span#tip').text('£' + parseFloat(net_tips, 10).toFixed(2))
    $('input#order_tip').val(net_tips)
    $('input#order_paid').val(total_paid)

  $(document).on "click", 'input.variant', (event) ->
    variant = $(event.target).data('id')
    $('input#variant_id').val(variant)

  $(document).on "change", 'select#balance', (event) ->
    $.ajax
      url: "/dailies?calendar=false&balance=true&daily_date=" + event.target.value
      dataType: 'script'

  $(document).on "change", 'select#cat', (event) ->
    start = $('input#start').val()
    stop = $('input#stop').val()
    choices = $("input[type='radio'][name='choices']:checked").val()
    $.ajax
      url: "/orders/analysis?start=" + start + "&stop=" + stop + "&choices=" + choices + "&cat=" + event.target.value
      dataType: 'script'
  $(document).on "change", 'select#sub', (event) ->
    start = $('input#start').val()
    stop = $('input#stop').val()
    cat = $('select#cat').val()
    choices = $("input[type='radio'][name='choices']:checked").val()
    $.ajax
      url: "/orders/analysis?start=" + start + "&stop=" + stop + "&choices=" + choices + "&cat=" + cat + "&sub=" + event.target.value
      dataType: 'script'
  $(document).on "change", 'select#item', (event) ->
    start = $('input#start').val()
    stop = $('input#stop').val()
    cat = $('select#cat').val()
    sub = $('select#sub').val()
    choices = $("input[type='radio'][name='choices']:checked").val()
    $.ajax
      url: "/orders/analysis?start=" + start + "&stop=" + stop + "&choices=" + choices + "&cat=" + cat + "&sub=" + sub + "&item=" + event.target.value
      dataType: 'script'
  $(document).on "change", "input[type='radio'][name='choices']", (event) ->
    start = $('input#start').val()
    stop = $('input#stop').val()
    choices = $("input[type='radio'][name='choices']:checked").val()
    $.ajax
      url: "/orders/analysis?start=" + start + "&stop=" + stop + "&choices=" + choices
      dataType: 'script'
  $(document).foundation orbit:
    animation: "fade" # Sets the type of animation used for transitioning between slides, can also be 'fade'
    timer_speed: 10000 # Sets the amount of time in milliseconds before transitioning a slide
    pause_on_hover: true # Pauses on the current slide while hovering
    resume_on_mouseout: true # If pause on hover is set to true, this setting resumes playback after mousing out of slide
    next_on_click: true # Advance to next slide on click
