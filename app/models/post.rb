class Post < ActiveRecord::Base

  # monetize :debit_amount_cents, :allow_nil => true
  # monetize :credit_amount_cents, :allow_nil => true

  def debit_amount
    debit_amount_cents / 100.00 if debit_amount_cents
  end
  def debit_amount=(val)
    self.debit_amount_cents = val ? val.to_d * 100 : 0
  end

  def credit_amount
    credit_amount_cents / 100.00 if credit_amount_cents
  end
  def credit_amount=(val)
    self.credit_amount_cents = val ? val.to_d * 100 : 0
  end

  belongs_to :postable, polymorphic: true
  belongs_to :accountable, polymorphic: true
  belongs_to :account
  belongs_to :grouping, class_name: 'Account'

  def accountable_name
    case accountable_name
      when 'Supplier'
        accountable.name
      else
        ''
    end
  end


end
