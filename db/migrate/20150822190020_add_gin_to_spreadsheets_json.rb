class AddGinToSpreadsheetsJson < ActiveRecord::Migration
  def change
    add_index  :spreadsheets, :spreadsheet_json, using: :gin
  end
end
