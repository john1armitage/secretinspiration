class ChoicesController < ApplicationController

  def index
    case current_tenant.domain
      when 'secret'
       # do_secret
      when 'shack', 'vernas'
    end
  end

  private

  def do_secret
    get_items
  end

  def get_items
      @items = Item.order('item_type_id').where( :variants => { :domain => current_tenant.domain } ).includes(:variants, :item_type)
  end

end
