class RolesController < ApplicationController


  def index
    @users = User.all #scope to current workforce
  end

  def create
    set_user
    if @user.role
      @user.role.update(:name => params[:role])
    else
      Role.create(:user_id => params[:user_id], :name => params[:role])
    end
    redirect_to roles_url
  end

  def destroy
    set_role
    @role.destroy
    redirect_to roles_url
  end

  private

  def set_role
    @role = Role.find( params[:id] )
  end

  def set_user
    @user = User.find( params[:user_id] )
  end

end