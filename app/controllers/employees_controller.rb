class EmployeesController < ApplicationController

  def index
    @employees = Employee.all
  end
  def show
    redirect_to action: :generate_payroll, id: params[:id]
  rescue ActiveRecord::RecordNotFound
    # Handle the case where the employee is not found
    redirect_to employees_path, alert: "Employee not found."
  end
  def new
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      redirect_to @employee, notice: 'Employee was successfully created.'
    else
      render :new
    end
  end

  def edit
    @employee = Employee.find(params[:id])
  end

  def update
    @employee = Employee.find(params[:id])
    if @employee.update(employee_params)
      redirect_to @employee, notice: 'Employee was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy
    redirect_to employees_path, notice: 'Employee was successfully deleted.'
  rescue ActiveRecord::RecordNotFound
    redirect_to employees_path, alert: 'Employee not found.'
  end

  def generate_payroll
    @employee = Employee.find(params[:id])
    @payroll_report = @employee.detailed_payroll_report
    @total_salary = @employee.compute_weekly_payroll
  rescue ActiveRecord::RecordNotFound
    redirect_to employees_path, alert: "Employee not found."
  end

  private
  def employee_params
    params.require(:employee).permit(:name, :daily_salary)
  end

end
