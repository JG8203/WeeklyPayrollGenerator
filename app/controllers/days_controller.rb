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

    if @day.update(converted_day_params)
      redirect_to employee_path(@employee)
    else
      render 'edit'
    end
  end

  private

  def day_params
    params.require(:day).permit(:in_time, :out_time, :is_rest, :day_type)
  end

  def converted_day_params
    converted_params = day_params
    converted_params[:in_time] = convert_to_string(converted_params[:in_time])
    converted_params[:out_time] = convert_to_string(converted_params[:out_time])
    converted_params
  end

  def convert_to_string(datetime_str)
    # Convert 'HH:MM' format to 'HHMM'
    DateTime.parse(datetime_str).strftime('%H%M') rescue datetime_str
  end
end
