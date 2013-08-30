class EmployeeSerializer < ActiveModel::Serializer
  attributes :id, :title, :first_name, :last_name, :date_of_birth, :ni_number, :address1, :address2, :town, :postcode, :mobile_phone, :home_phone, :start_date, :end_date
end
