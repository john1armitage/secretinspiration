class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy]

  # GET /bookings
  def index
    #@bookings = Booking.order('booking_date DESC, arrival')
    @booking_date = params['booking_date'].present? ? params['booking_date'] : Date.today
    @bookings = Booking.where( :booking_date => @booking_date )

    @bookings_by_date = get_bookings(@booking_date)
    @bookings_next_month = get_bookings(@booking_date + 1.month)
  end

  # GET /bookings/1
  def show
  end

  # GET /bookings/new
  def new
    get_tables
    @booked_tabels = []
    @booking = Booking.new
    @booking.booking_date = Date.today.to_s
    if params[:walk_in].present?
      @booking.walkin = true
      @booking.customer_name = 'Walk-in'
      @booking.arrival = Time.now.to_s(:time)
    end
  end

  # GET /bookings/1/edit
  def edit
    get_tables
    get_booked
  end

  # POST /bookings
  def create
    @booking = Booking.new(params[:booking])
    @booking.user_id = @current_user.id
    if @booking.save
      set_booked
      redirect_to bookings_url, notice: 'Booking was successfully created.'
    else
      update_booked
      get_tables
      render action: 'new'
    end
  end

  # PATCH/PUT /bookings/1
  def update
    set_booked
    params[:booking][:user_id] = current_user.id
    if @booking.update(params[:booking])
      redirect_to bookings_url, notice: 'Booking was successfully updated.'
    else
      get_tables
      update_booked
      render action: 'edit'
    end
  end

  # DELETE /bookings/1
  def destroy
    @booking.destroy
    redirect_to bookings_url, notice: 'Booking was successfully destroyed.'
  end

  private
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

    def get_bookings(booking_date)
      start = booking_date.beginning_of_month
      stop = booking_date.end_of_month
      @bookings.where('booking_date >= ? AND booking_date <= ?', start, stop ).group_by(&:booking_date)
      @bookings.where('booking_date >= ? AND booking_date <= ?', start, stop ).group_by(&:booking_date)

    end

    def get_tables
      @tabels = Tabel.order('name::INT')
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
      @current_resource ||= Booking.find(params[:id])  if params[:id]
    end


  # Only allow a trusted parameter "white list" through.
    #def booking_params
    #  params.require(:booking).permit(:customer_id, :user_id, :arrival, :state,
    #            :pax, :notes, :customer_name, :booking_date, :contact)
    #end
end
