# for more details see: http://emberjs.com/guides/models/defining-models/

Commerce.Opening = DS.Model.extend
  startDate: DS.attr 'date'
  repeat: DS.attr 'number'
  frequency: DS.attr 'string'
  string: DS.attr 'string'
  status: DS.attr 'string'
  message: DS.attr 'string'
  string: DS.attr 'string'
