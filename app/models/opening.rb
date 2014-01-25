class Opening < ActiveRecord::Base

  validates_presence_of :start_date, :message => 'is required'


  def finish_date
    if end_date
      end_date
    else
      start_date + eval("#{repeat - 1}.#{frequency}")
    end
  end
end
