class Posting < ActiveRecord::Base

  # monetize :debit_amount_cents
  # monetize :credit_amount_cents

  belongs_to :postable, polymorphic: true
  belongs_to :accountable, polymorphic: true
  belongs_to :account

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

  def accountable_name
    case accountable_name
      when 'Supplier'
        accountable.name
      else
        ''
    end
  end

 # default_scope { order('event_date DESC, postable_type, postable_id') }

end
