class CreateSpreadsheets < ActiveRecord::Migration
  def change
    create_table :spreadsheets, id: :uuid do |t|
      t.string :description
      t.json :table_json
      t.uuid :service_id
      t.uuid :laboratory_id
      t.timestamps
    end
    add_index :spreadsheets, :laboratory_id
  end
end
