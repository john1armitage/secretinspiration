#thanks
  .row
    .large-12.columns
      %p
        %span.title
          Thanks!
        %span
          We've got your booking request. 
      %p
        %span.title
          PLEASE check any Junk folder if you do not see our Email. 
      %p 
        %span
          In case of ANY DOUBT, please just give us a call.
  .row
    .large-12.columns
      %p
        %span.title
          != @booking.booking_date.strftime("%a %e-%b-%y")
        %br
        %span
          != pluralize(@booking.pax, 'person')
        %span
          at
          != @booking.arrival.strftime("%H:%M")
      - unless @booking.notes.blank?
        %p
          = "\"#{@booking.notes}\""
  .row
    .large-12.columns
      %p
        %span.title
          != @booking.customer_name
        %br
        %span
          != @booking.contact
        %br
        %span
          != @booking.email

