class Wage < ActiveRecord::Base

  monetize :rate_cents, :allow_nil => false,
           :numericality => {
               :greater_than_or_equal_to => 0
           }
  monetize :gross_cents, :allow_nil => false,
           :numericality => {
               :greater_than_or_equal_to => 0
           }
  monetize :NI_employer_cents, :allow_nil => true,
           :numericality => {
               :greater_than_or_equal_to => 0
           }
  monetize :NI_employee_cents, :allow_nil => true,
           :numericality => {
               :greater_than_or_equal_to => 0
           }
  monetize :PAYE_cents, :allow_nil => true,
           :numericality => {
               :greater_than_or_equal_to => 0
           }
  monetize :tips_cents, :allow_nil => true,
           :numericality => {
               :greater_than_or_equal_to => 0
           }
  monetize :holiday_cents, :allow_nil => true,
           :numericality => {
               :greater_than_or_equal_to => 0
           }
  monetize :bonus_cents, :allow_nil => true,
           :numericality => {
               :greater_than_or_equal_to => 0
           }

  belongs_to :employee

  has_many  :posts, as: :postable, dependent: :destroy

  after_create

  validates_presence_of :employee_id, :message => 'is required'

  default_scope { order(:FY, :week_no) }

  def name
    employee.first_name
  end

end
