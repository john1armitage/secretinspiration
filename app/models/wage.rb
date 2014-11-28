class Wage < ActiveRecord::Base

  monetize :rate_cents, :allow_nil => false,
           :numericality => {
               :greater_than => 0
           }
  monetize :gross_cents, :allow_nil => false,
           :numericality => {
               :greater_than => 0
           }
  monetize :NI_employer_cents, :allow_nil => true,
           :numericality => {
               :greater_than => 0
           }
  monetize :NI_employee_cents, :allow_nil => true,
           :numericality => {
               :greater_than => 0
           }
  monetize :PAYE_cents, :allow_nil => true,
           :numericality => {
               :greater_than => 0
           }
  monetize :tips_cents, :allow_nil => true,
           :numericality => {
               :greater_than => 0
           }

  belongs_to :employee

  after_create

  validates_presence_of :employee_id, :message => 'is required'



end
