class AddSpreadsheetJsonToSpreadsheets < ActiveRecord::Migration
  def change
    add_column :spreadsheets, :spreadsheet_json, :json
  end
end
