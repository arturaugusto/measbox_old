class AddCalibrationDateToServices < ActiveRecord::Migration
  def change
    add_column :services, :calibration_date, :datetime
  end
end
