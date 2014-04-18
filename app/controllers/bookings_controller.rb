class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy, :status]

  # GET /bookings
  def index
    #@bookings = Booking.order('booking_date DESC, arrival')
    set_booking_dates
  end

  def dated
    @booking_date = params['booking_date'].present? ? params['booking_date'].to_date : Date.today
    @bookings = Booking.where( booking_date: @booking_date )
    @bookings = @bookings.where('state <> ?', params[:state]) if params[:not].present?
  end
  # GET /bookings/1
  def show
  end

  # GET /bookings/new
  def new
    get_tables
    @booked_tabels = []
    @booking = Booking.new
    @booking.state = 'incomplete'
    @booking.booking_date = params[:date].present? ? params[:date] : Date.today.to_s
    if params[:walk_in].present?
      @booking.walkin = true
      @booking.customer_name = 'Walk-in'
      @booking.arrival = Time.now.to_s(:time)
    end
    unless  @current_user.id.blank?
      @booking.confirmed = true
    end
    render 'form'
  end

  # GET /bookings/1/edit
  def edit
    get_tables
    get_booked
    render 'form'
  end

  # POST /bookings
  def create
    @booking = Booking.new(params[:booking])
    if  @current_user.id.blank?
      @booking.user_id = User.find_by_username('system').id
      @booking.confirmed = false
      @booking.state = 'incomplete'
      @booking.IP = request.remote_addr
      @request = true
    else
      @booking.user_id = @current_user.id
    end
    set_session
    if @booking.save
      set_booked
      set_booking_dates
      if @current_user.id.blank? && !@booking.email.blank?
        BookingMailer.booking_ack(@booking, current_tenant).deliver
      end
      render 'index'
    else
      update_booked
      get_tables
      render 'form'
    end
  end

  # PATCH/PUT /bookings/1
  def update
    set_booked
    params[:booking][:user_id] = current_user.id
    set_session
    if @booking.update(params[:booking])
      set_booking_dates
      render 'index'
    else
      get_tables
      update_booked
      render 'form'
    end
  end

  def status
    @booking.update_attribute(:state, params[:status])
    set_booking_dates
    render 'index'
  end

  # DELETE /bookings/1
  def destroy
    @booking.destroy
    set_booking_dates
    render 'index'
  end

  private
    def set_session
      @booking.session = (@booking.arrival.strftime('%H').to_i < 17) ? 'lunch' : 'dinner'
    end

    def update_booked
      if @booking.new_record?
        @new_booked = []
        if params[:tabels].present?
          params[:tabels].each do |k, v|
            @new_booked << k
          end
        end
      end
      @booked_tabels = @new_booked
    end

   #def set_booking_dates
   #  @booking_date = params['booking_date'].present? ? params['booking_date'] : Date.today
   #  @bookings = Booking.where( :booking_date => @booking_date )
   #  @bookings_by_date = get_bookings(@booking_date)
   #  @bookings_next_month = get_bookings(@booking_date + 1.month)
   #end

  #def get_bookings(booking_date)
  #    start = (booking_date <= Time.now.at_beginning_of_day) ? Time.now.to_date : booking_date.beginning_of_month
  #    stop = booking_date.end_of_month
  #    Booking.where('booking_date >= ? AND booking_date <= ?', start, stop ).group_by(&:booking_date)
  #  end

    def get_tables
      # @tabels = Tabel.order('name::INT')
      @tabels = Tabel.order('name::INT')
      if @booking
        booking_date = @booking.booking_date
        id = @booking.id
      else
        booking_date = params[:date]
        id = -1
      end
      @booked = Tabel.joins(seatings: :booking ).where('bookings.booking_date = ? AND bookings.id <> ?', booking_date, id).order('name::INT')
      @tabels  -= @booked
    end

    def get_booked
      @booked_seatings = @booking.seatings.all
      @booked_tabels = @booked_seatings.map {|s| s.tabel.name }
    end

    def set_booked
      get_booked
      @new_booked = []
      if  params[:tabels]
        params[:tabels].each do |k, v|
          @new_booked << k
          @booking.seatings.create( :tabel_id => k ) unless @booked_tabels.include?( k )
        end
      end
      @booked_seatings.each do |old|
        old.destroy unless @new_booked.include?( old.tabel.name )
      end
    end

  # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    def current_resource
      @current_resource ||= @booking
  #    @current_resource ||= Booking.find(params[:id]) if params[:id]
    end


  # Only allow a trusted parameter "white list" through.
    #def booking_params
    #  params.require(:booking).permit(:customer_id, :user_id, :arrival, :state,
    #            :pax, :notes, :customer_name, :booking_date, :contact)
    #end
end
