class BookingMailer < ActionMailer::Base
  default from: CONFIG[:mail_sender],
          bcc: [CONFIG[:mail_sender], 'bunsitajones@gmail.com']
  def booking_ack(booking)
    @booking = booking
    mail :to => booking.email, :subject => "Pepper Shack request: #{booking.booking_date.strftime('%e-%b-%y')}"
  end

end
