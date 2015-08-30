class Post < ActiveRecord::Base

  monetize :debit_amount_cents, :allow_nil => true
  monetize :credit_amount_cents, :allow_nil => true

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
