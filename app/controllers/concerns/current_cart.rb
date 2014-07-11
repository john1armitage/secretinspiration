module CurrentCart
  extend ActiveSupport::Concern
  private
  def set_takeaway
    if params[:meal_id].present?
      # @page = Page.find_by_code('catalogue')
      begin
        @meal = Meal.find(params[:meal_id])
      rescue  ActiveRecord::RecordNotFound
        get_user_takeaway
      end
    else
      @page = Page.find_by_code(params[:code])
      get_user_takeaway
    end
  end

  def get_user_takeaway
    @meal = Meal.find(session[:meal_id])
  rescue ActiveRecord::RecordNotFound
    @meal = Meal.create(tabel_name: request.remote_addr, start_time: Time.now, state: 'takeaway')
    session[:meal_id] = @meal.id
    @meal
  end

  def set_cart
    if params[:cart_id].present?
      cart_id = params[:cart_id]
    elsif session[:cart_id].present?
      cart_id = session[:cart_id]
    end
    if cart_id
      # @page = Page.find_by_code('catalogue')
      begin
        @cart = Cart.find(cart_id)
      rescue  ActiveRecord::RecordNotFound
        get_user_cart
      end
    else
      # @page = Page.find_by_code(params[:code])
      get_user_cart
    end
  end

  def get_user_cart
    if current_user.id.blank?
      @cart = Cart.find(session[:cart_id])
    else
      @cart = current_user.carts.first || Cart.create( user_id: current_user.id )
      # @cart = Cart.create( user_id: current_user.id, domain: current_tenant.domain )
     session[:cart_id] = @cart.id
    end
  rescue ActiveRecord::RecordNotFound
    # @cart = Cart.create(IP: request.remote_addr, domain: current_tenant.domain)
    @cart = Cart.create(IP: request.remote_addr)
    session[:cart_id] = @cart.id
    @cart
  end
end