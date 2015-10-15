# for more details see: http://emberjs.com/guides/models/defining-models/

Commerce.Recipe = DS.Model.extend
  itemId: DS.attr 'intger'
  ingredientId: DS.attr 'number'
  amountId: DS.attr 'number'
