module CurrentCart
  extend ActiveSupport::Concern
  private
  def set_cart
    if params[:cart_id].present?
      @page = Page.find_by_code('catalogue')
      begin
        @cart = Cart.find(params[:cart_id])
      rescue  ActiveRecord::RecordNotFound
        get_user_cart
      end
    else
      @page = Page.find_by_code(params[:code])
      get_user_cart
    end
  end

  def get_user_cart
    unless current_user.id.blank?
      @cart = current_user.cart || Cart.create( :user_id => current_user.id )
    else
      @cart = Cart.find(session[:cart_id])
    end
  rescue ActiveRecord::RecordNotFound
    @cart = Cart.create
    session[:cart_id] = @cart.id
    @cart
  end
end