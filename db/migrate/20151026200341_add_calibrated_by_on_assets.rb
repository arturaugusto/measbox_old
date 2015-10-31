class AddCalibratedByOnAssets < ActiveRecord::Migration
  def change
    add_column :assets, :calibrated_by, :string
  end
end
