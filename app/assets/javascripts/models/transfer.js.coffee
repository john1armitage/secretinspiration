Commerce.Transfer = DS.Model.extend
  transferDate: DS.attr('date')
  bank: DS.attr('belongs_to')
  recipient: DS.attr('belongs_to')
  exchangeRate: DS.attr('number')
