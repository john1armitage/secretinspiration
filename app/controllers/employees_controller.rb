class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]

  # GET /employees
  def index
    @employees = Employee.all
  end

  # GET /employees/1
  def show
  end

  # GET /employees/new
  def new
    @employee = Employee.new
  end

  # GET /employees/1/edit
  def edit
  end

  # POST /employees
  def create
    @employee = Employee.new(params[:employee])

    if @employee.save
      redirect_to employees_url, notice: 'Employee was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /employees/1
  def update
    if @employee.update(params[:employee])
      redirect_to employees_url, notice: 'Employee was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /employees/1
  def destroy
    @employee.destroy
    redirect_to employees_url, notice: 'Employee was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Employee.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @employee
  end
end
