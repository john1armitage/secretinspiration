class BookingMailer < ActionMailer::Base
  default from: CONFIG[:mail_sender],
          bcc: [CONFIG[:mail_sender]]
  def booking_ack(booking, current_tenant)
    @booking = booking
    @total_booked = Booking.where("booking_date = ? and state <> 'cancelled'", booking.booking_date).sum(&:pax)
    @current_tenant = current_tenant
    mail :to => booking.email, :subject => "Pepper Shack request: #{booking.booking_date.strftime('%e-%b-%y')}"
  end

end
