class WageSerializer < ActiveModel::Serializer
  attributes :id, :FY, :week_no, :hours, :rate, :net, :NI_employer, :NI_employee, :PAYE, :tips, :money, :paid_date
  has_one :employee
end
