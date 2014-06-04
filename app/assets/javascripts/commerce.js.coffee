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
  $(document).on "click", 'input#cash_payment', (event) ->
    voucher = parseFloat($('input#order_voucher').val())
    total_paid = parseFloat($('input#total').val()) + parseFloat($('input#cash').val()) + parseFloat($('input#order_tip').val())  + voucher
    order_total = parseFloat($('input#order_total').val())
    $('input#order_credit_card').val(0.00)
    if parseFloat(total_paid) > 0.00
      if total_paid >= order_total
        $('input#order_paid').val(order_total - voucher)
        $('input#order_tip').val(total_paid - order_total)
      else
        $('input#order_paid').val(total_paid - voucher)
        $('input#order_tip').val(0.00)
  $(document).on "click", 'input#card_payment', (event) ->
    credit_card = parseFloat($('input#total').val())
    $('input#order_credit_card').val(credit_card)
    cash = parseFloat($('input#cash').val())
    order_total = parseFloat($('input#order_total').val())
    voucher = parseFloat($('input#order_voucher').val())
    total_paid = credit_card + cash + parseFloat($('input#order_tip').val())  + voucher
    if parseFloat(total_paid) > 0.00
      if total_paid >= order_total
        $('input#order_paid').val(order_total - voucher)
        $('input#order_tip').val(total_paid - order_total)
      else
        $('input#order_paid').val(total_paid - voucher)
        $('input#order_tip').val(0.00)
  $(document).on "click", 'input.variant', (event) ->
    variant = $(event.target).data('id')
    $('input#variant_id').val(variant)

  $(document).on "change", 'select#balance', (event) ->
    $.ajax
      url: "/dailies?calendar=false&balance=true&daily_date=" + event.target.value
      dataType: 'script'