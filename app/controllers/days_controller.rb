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

    converted_params = day_params
    converted_params[:in_time] = convert_to_string(converted_params[:in_time])
    converted_params[:out_time] = convert_to_string(converted_params[:out_time])

    if @day.update(converted_params)
      redirect_to employee_path(@employee)
    else
      render 'edit'
    end
  end

  private

  def day_params
    params.require(:day).permit(:in_time, :out_time, :is_rest, :day_type)
  end

  def convert_to_string(datetime_str)
    # Assuming the datetime_str is in the format 'YYYY-MM-DDTHH:MM'
    DateTime.parse(datetime_str).strftime('%H%M') rescue datetime_str
  end
end
