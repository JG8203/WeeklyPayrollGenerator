class Day < ApplicationRecord
  belongs_to :employee
  validates :in_time, presence: true
  validates :out_time, presence: true
end
