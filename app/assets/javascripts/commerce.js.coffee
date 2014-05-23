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
    total = parseFloat($('input#total').val()) + parseFloat($('input#order_tip').val())
    due = parseFloat($('input#due').val())
    $('input#order_credit_card').val(0)
    if total != null and total > 0
      if total >= due
        $('input#order_paid').val(due)
        $('input#order_tip').val(total - due)
      else
        $('input#order_paid').val(total)
        $('input#order_tip').val(0)
  $(document).on "click", 'input#card_payment', (event) ->
    credit_card = parseFloat($('input#total').val())
    $('input#order_credit_card').val(credit_card)
    total = credit_card + parseFloat($('input#cash').val()) + parseFloat($('input#order_tip').val())
    due = parseFloat($('input#due').val())
    if total != null and total > 0
      if total >= due
        $('input#order_paid').val(due)
        $('input#order_tip').val(total - due)
      else
        $('input#order_paid').val(total)
        $('input#order_tip').val(0)
  $(document).on "click", 'input.variant', (event) ->
    variant = $(event.target).data('id')
    $('input#variant_id').val(variant)

  $(document).on "change", 'select#balance', (event) ->
    $.ajax
      url: "/dailies?calendar=false&balance=true&daily_date=" + event.target.value
      dataType: 'script'