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
    $(document).on "click", 'form.contact input', (event) ->
      $contact = $('input#meal_contact').val().trim()
      $phone = $('input#meal_phone').val().trim()
      $notes = $('textarea#meal_notes').val()
      $start_time = $('select#meal_start_time option:selected').val()
      $meal_id = $('input#meal_id').val()
      event.preventDefault()
      if $contact.replace(/\W+/g,'').length < 3
        alert('Please check Contact Name ' + $contact + $phone)
        return
      if $phone.replace(/\D+/g,'').length < 6
        alert('Please check Phone Number: ' + $phone)
        return
      $.post( "/meals/" + $meal_id + "/patcher", { takeaway: 'request', contact: $contact, phone: $phone, start_time: $start_time, notes: $notes } )
    $(document).on "click", 'a#print', (event) ->
      $('.no-print').hide()
      window.print()
      $('.no-print').show()
      event.preventDefault()
    $(document).on "click", 'a.no_content', (event) ->
      $('div#content').html('')

    $(document).on "click", 'form.menu-item input', (event) ->
      event.preventDefault()
      $meal_id = $('input#meal_id').val().trim()
      $variant_id = $(event.target).data('id')
      $.post( "/meal_items", { meal_id: $meal_id, variant_id: $variant_id } )
