module CurrentCart
  extend ActiveSupport::Concern
  private
  def set_cart
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