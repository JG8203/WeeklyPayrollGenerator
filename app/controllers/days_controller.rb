class DaysController < ApplicationController
  def show
    @employee = Employee.find(params[:employee_id])
    @day = @employee.days.find(params[:id])
  end

  def edit
    @employee = Employee.find(params[:employee_id])
    @day = @employee.days.find(params[:id])
  end

  def update
    @employee = Employee.find(params[:employee_id])
    @day = @employee.days.find(params[:id])

    if @day.update(day_params)
      redirect_to employee_path(@employee)
    else
      render 'edit'
    end
  end

  private

  def day_params
    params.require(:day).permit(:in_time, :out_time, :is_rest, :day_type)
  end
end
