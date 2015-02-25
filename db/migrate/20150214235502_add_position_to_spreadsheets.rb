class AddPositionToSpreadsheets < ActiveRecord::Migration
  def change
    add_column :spreadsheets, :position, :integer
  end
end
