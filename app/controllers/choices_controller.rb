class ChoicesController < ApplicationController

  include CurrentCart

  def index
    set_cart if params[:cart].present?
    choices = params[:choices].present? ? params[:choices] : default_choices
    @categories = get_categories(choices)
    @page = Page.find_by_code( choices )
  end

  private

  def get_items
      @items = Item.order('item_type_id').where( :variants => { :domain => current_tenant.domain } ).includes(:variants, :item_type)
  end

end
