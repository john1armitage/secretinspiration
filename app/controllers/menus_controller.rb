class MenusController < ApplicationController

  include CurrentCart

  before_action :set_cart, only: [:show]


  #def show
  #  p params[:id]
  # #  render "layouts/menus/_#{params[:id]}",  layout: false
  #  render :update do |page|
  #    page.replace_html 'menu', :partial => "layouts/menus/#{params[:id]}"
  #  end
  #
  #end

end
