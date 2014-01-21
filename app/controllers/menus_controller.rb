class MenusController < ApplicationController

  include CurrentCart

  before_action :set_cart, only: [:show]


  def sub
    @page = Page.find_by_code(params[:id])
  end

end
