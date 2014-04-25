# for more details see: http://emberjs.com/guides/models/defining-models/

Commerce.PayRate = DS.Model.extend
  employee: DS.belongsTo 'Commerce.Employee'
  effectiveDate: DS.attr 'date'
  rate: DS.attr 'money'
