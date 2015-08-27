class Post < ActiveRecord::Base

  monetize :debit_amount_cents
  monetize :credit_amount_cents

  belongs_to :postable, polymorphic: true
  belongs_to :accountable, polymorphic: true
  belongs_to :account

  def accountable_name
    case accountable_name
      when 'Supplier'
        accountable.name
      else
        ''
    end
  end


end
