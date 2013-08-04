jQuery ->
  Account =
    checkQuick: (quick) ->
      if quick
        $('div.row.quick').show()
        $('div.row.line-items').hide()
      else
        $('div.row.quick').hide()
        $('div.row.line-items').show()
#  Meal =
#    addItem: (variantId, mealId) ->
#      alert( variantId + "Not Yet!")
#      meal_items_path(variant_id: variant.id)