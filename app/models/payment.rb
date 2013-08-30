class Payment < ActiveRecord::Base

  include AccountPosting

  monetize :amount_cents
  monetize :home_amount_cents

  has_many :allocations, dependent: :destroy
  has_many :orders, through: :allocations

  has_many  :postings, as: :postable, dependent: :destroy
  belongs_to :bank

  belongs_to :payable, polymorphic: true

  belongs_to :account

  accepts_nested_attributes_for :allocations, :allow_destroy => true

  default_scope { order('payment_date DESC') }

  def postings
    bank_account = Account.find_by_name( bank.name ).id
    create_posting( 'Payment', id, false, amount_cents, account_id, payable_type, payable_id, false, payment_date)
    create_posting( 'Payment', id, true, amount_cents, bank_account, payable_type, payable_id, false, payment_date)
  end

  def hmrc_postings( ni_employee, ni_employer, paye )
    create_posting( 'Payment', id, false, ni_employee * 100, Account.find_by_name('NI Employee due').id, payable_type, payable_id, false, payment_date) if ni_employee > 0
    create_posting( 'Payment', id, false, ni_employer * 100, Account.find_by_name('NI Employer due').id, payable_type, payable_id, false, payment_date) if ni_employee > 0
    create_posting( 'Payment', id, false, paye * 100, Account.find_by_name('PAYE due').id, payable_type, payable_id, false, payment_date) if ni_employee > 0
    create_posting( 'Payment', id, true, amount_cents, Account.find_by_name('HMRC Control').id, payable_type, payable_id, false, payment_date)
  end

  def payroll_postings( ni_employee, ni_employer, paye )
    create_posting( 'Payment', id, true, ni_employee * 100, Account.find_by_name('NI Employee due').id, payable_type, payable_id, false, payment_date) if ni_employee > 0
    create_posting( 'Payment', id, true, ni_employer * 100, Account.find_by_name('NI Employer due').id, payable_type, payable_id, false, payment_date) if ni_employer > 0
    create_posting( 'Payment', id, true, paye * 100, Account.find_by_name('PAYE due').id, payable_type, payable_id, false, payment_date) if paye > 0
    holiday_pay = amount_cents * 12 / 100
    create_posting( 'Payment', id, true, holiday_pay, Account.find_by_name('Holiday Pay').id, payable_type, payable_id, false, payment_date) if holiday_pay > 0
    liability =  ni_employee * 100 + ni_employer * 100 + paye * 100 + holiday_pay
    create_posting( 'Payment', id, false, liability, account_id, payable_type, payable_id, false, payment_date)
  end

end
