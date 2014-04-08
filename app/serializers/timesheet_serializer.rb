class TimesheetSerializer < ActiveModel::Serializer
  attributes :id, :employee, :hours
end
