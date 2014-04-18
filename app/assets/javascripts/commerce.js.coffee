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

  $('ul.dropdown li:not(.title),li.level-one').on 'click', (event) ->
    $('li.menu-icon').click()
    $('div#editor').html('')
  $(document).on "click", 'input[value="Cancel"]', (event) ->
    event.preventDefault()
    $(this).parents().find('div#editor').html('')
#  $(document).on "click", 'form.contact input', (event) ->
#    $contact = $('input#meal_contact').val().trim()
#    $phone = $('input#meal_phone').val().trim()
#    $notes = $('textarea#meal_notes').val()
#    $start_time = $('select#meal_start_time option:selected').val()
#    $meal_id = $('input#meal_id').val()
#    event.preventDefault()
#    if $contact.replace(/\W+/g,'').length < 3
#      alert('Please check Contact Name ' + $contact + $phone)
#      return
#    if $phone.replace(/\D+/g,'').length < 6
#      alert('Please check Phone Number: ' + $phone)
#      return
#    $.post( "/meals/" + $meal_id + "/patcher", { takeaway: 'request', contact: $contact, phone: $phone, start_time: $start_time, notes: $notes } )
  $(document).on "click", 'a#print', (event) ->
    $('.no-print').hide()
    window.print()
    $('.no-print').show()
    event.preventDefault()
  $(document).on "click", 'a.no_content', (event) ->
    $('div#content').html('')
  $(document).on "click", 'input#bill_payment', (event) ->
    total = $('input#total').val()
    tip = $('input#order_tip').val()
    paid = $('input#order_paid').val()
    due = $('input#due').val()
    if total != null and total > 0
      if tip > 0
        $('input#order_paid').val(due)
      else if total >= due
        $('input#order_paid').val(due)
        $('input#order_tip').val(total - due)
      else if total < due
        $('input#order_paid').val(total)
        $('input#order_tip').val(0)
  $(document).on "click", 'input.variant', (event) ->
    variant = $(event.target).data('id')
    $('input#variant_id').val(variant)
#  $(document).on "change", 'input#gross', (event) ->
#    console.log event.target
#    alert('woof')
#    gross = $('input#gross').val()
#    alert(gross)
#    if gross != null and gross != 0
#      alert('woofle')
#      net = gross / 1.2
#      tax = gross - net
#      $('input#daily_turnover').val(net)
#      $('input#daily_tax').val(tax)
