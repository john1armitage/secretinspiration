class Employee < ActiveRecord::Base

  def name
    title + " " + first_name + " " + last_name + " "
  end
end
