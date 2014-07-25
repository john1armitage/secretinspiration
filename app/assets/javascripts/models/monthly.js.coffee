# for more details see: http://emberjs.com/guides/models/defining-models/

Commerce.Monthly = DS.Model.extend
  takings: DS.attr 'string'
  creditCard: DS.attr 'string'
  cash: DS.attr 'string'
  tax: DS.attr 'string'
  turnover: DS.attr 'string'
  cashUsed: DS.attr 'string'
