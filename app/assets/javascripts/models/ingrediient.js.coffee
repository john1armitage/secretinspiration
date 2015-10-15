# for more details see: http://emberjs.com/guides/models/defining-models/

Commerce.Ingrediient = DS.Model.extend
  name: DS.attr 'string'
  supplierId: DS.attr 'number'
  reference: DS.attr 'string'
  quantity: DS.attr 'number'
  unitId: DS.attr 'number'
  live: DS.attr 'boolean'
  notes: DS.attr 'string'
  text: DS.attr 'string'
