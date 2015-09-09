class ChangeSpreadsheetJsonType < ActiveRecord::Migration
  def change
    change_column :spreadsheets, :spreadsheet_json, 'jsonb USING CAST(spreadsheet_json AS jsonb)', null: false, default: '{}' 
  end
end
