class Employee < ApplicationRecord
  has_many :days, dependent: :destroy

  # Callbacks
  before_create :set_default_daily_salary
  after_create :create_default_days

  # Public methods
  def compute_weekly_payroll
    self.days.sum { |day| compute_daily_salary(day) }
  end

  def detailed_payroll_report
    self.days.each_with_index.map do |day, index|
      detailed_day_report(day, index)
    end
  end

  def compute_weekly_absences
    self.days.where("in_time = out_time").count
  end

  private

  # Callback methods
  def set_default_daily_salary
    self.daily_salary ||= 500
  end

  def create_default_days
    7.times { |i| self.days.create(default_day_attributes(i)) }
  end

  # Helper methods for detailed_payroll_report
  def detailed_day_report(day, index)
    hourly_rate = self.daily_salary / 8
    overtime_hours, regular_night_shift_hours, overtime_night_shift_hours = calculate_hours(day.in_time, day.out_time)

    # Calculate total hours worked
    total_hours = ((DateTime.strptime(day.out_time, '%H%M') - DateTime.strptime(day.in_time, '%H%M')) * 24).to_i
    total_hours += 24 if day.out_time < day.in_time # If working past midnight

    {
      day_number: index + 1,
      id:day.id,
      in_time: day.in_time,
      out_time: day.out_time,
      total_hours: total_hours,
      regular_night_shift_hours: regular_night_shift_hours,
      overtime_hours: overtime_hours,
      overtime_night_shift_hours: overtime_night_shift_hours,
      is_rest: day.is_rest,
      day_type: day.day_type,
      daily_salary: compute_daily_salary(day)
    }
  end

  def default_day_attributes(index)
    { day_type: "Normal Day", in_time: "0900", out_time: "0900", is_rest: index >= 5 }
  end

  def calculate_hours(in_time, out_time)
    in_dt = DateTime.strptime(in_time, '%H%M')
    out_dt = DateTime.strptime(out_time, '%H%M')
    # Ensure these are integers representing the hours
    night_shift_start = 22
    night_shift_end = 6
    # Add one day to out_dt if out time is on the next day
    out_dt += 1 if out_dt < in_dt

    overtime_start = in_dt + Rational(9, 24) # 9 hours after in_time

    overtime_hours = 0
    regular_night_shift_hours = 0
    overtime_night_shift_hours = 0

    current_time = in_dt
    while current_time < out_dt
      hour_of_day = current_time.hour
      is_night_shift = hour_of_day >= night_shift_start || hour_of_day < night_shift_end
      is_overtime = current_time >= overtime_start

      if is_night_shift
        if is_overtime
          overtime_night_shift_hours += 1
        else
          regular_night_shift_hours += 1
        end
      elsif is_overtime
        overtime_hours += 1
      end

      # Move to the next hour
      current_time += Rational(1, 24)
    end

    [overtime_hours, regular_night_shift_hours, overtime_night_shift_hours]
  end

  # Salary computation methods
  def compute_daily_salary(day)
    # Check if the employee is absent
    is_absent = day.in_time == day.out_time

    # If the employee is absent and it's not a rest day, return 0
    return 0 if is_absent && !day.is_rest

    # Calculate the base salary based on day type and rest day status
    base_salary = calculate_base_salary(day, is_absent)

    # If it's a rest day or the employee is absent, return the base salary
    return base_salary if day.is_rest && is_absent

    # Proceed with regular salary calculation
    hourly_rate = self.daily_salary / 8
    overtime_hours, regular_night_shift_hours, overtime_night_shift_hours = calculate_hours(day.in_time, day.out_time)

    ot_salary = calculate_ot_salary(day, overtime_hours, hourly_rate)
    ns_salary = regular_night_shift_hours * (hourly_rate * 1.10) # Night Shift Calculation
    otns_salary = overtime_night_shift_hours * (calculate_ot_rate(day, hourly_rate) * 1.10) # Overtime Night Shift Calculation

    base_salary + ot_salary + ns_salary + otns_salary
  end

  def calculate_base_salary(day, is_absent)
    case day.day_type
    when "Normal Day"
      # For a normal rest day with no work, return regular salary
      return self.daily_salary if day.is_rest && is_absent
      # For a normal working day or rest day with work done, calculate accordingly
      day.is_rest ? self.daily_salary * 1.3 : self.daily_salary
    when "SNWH" # Special Non-Working Holiday
      day.is_rest ? self.daily_salary * 1.5 : self.daily_salary * 1.3
    when "RH" # Regular Holiday
      day.is_rest ? self.daily_salary * 2.6 : self.daily_salary * 2
    else
      self.daily_salary
    end
  end


  def calculate_ot_salary(day, overtime_hours, hourly_rate)
    overtime_hours * calculate_ot_rate(day, hourly_rate)
  end

  def calculate_ot_rate(day, hourly_rate)
    case day.day_type
    when "Normal Day"
      day.is_rest ? hourly_rate * 1.69 : hourly_rate * 1.25
    when "SNWH" # Special Non-Working Holiday
      day.is_rest ? hourly_rate * 1.95 : hourly_rate * 1.69
    when "RH" # Regular Holiday
      day.is_rest ? hourly_rate * 3.38 : hourly_rate * 2.6
    else
      hourly_rate
    end
  end
end
