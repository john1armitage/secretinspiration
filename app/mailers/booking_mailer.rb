class BookingMailer < ActionMailer::Base
  default from: CONFIG[:mail_sender],
          bcc: [CONFIG[:mail_sender]]
  def booking_ack(booking, current_tenant)
    @booking = booking
    @total_booked = Booking.where("booking_date = ? and state <> 'cancelled'", booking.booking_date).sum(&:pax)
    @current_tenant = current_tenant
    email = booking.email.blank? ? [CONFIG[:mail_sender]] : booking.email
    mail to: email, :subject => "Pepper Shack request: #{booking.booking_date.strftime('%e-%b-%y')}"
  end

  def booking_conf(booking, current_tenant, notes)
    @booking = booking
    @notes = notes
    @current_tenant = current_tenant
    email = booking.email.blank? ? [CONFIG[:mail_sender]] : booking.email
    mail to: email, :subject => "Pepper Shack Booking Confirmed: #{booking.booking_date.strftime('%e-%b-%y')}"
  end
end
