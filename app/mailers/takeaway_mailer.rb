class TakeawayMailer < ActionMailer::Base
  default from: CONFIG[:mail_sender],
          bcc: CONFIG[:mail_sender]
  def takeaway_notify(meal)
    @meal = meal
    mail :to => CONFIG[:mail_sender], :subject => "Takeaway for #{meal.start_time.strftime('%H:%M')}: #{meal.contact} on #{meal.phone}"
  end

end
