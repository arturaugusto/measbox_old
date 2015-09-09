class ChangeJsonToJsonb < ActiveRecord::Migration
  def change
    change_column :spreadsheets, :table_json, 'jsonb USING CAST(table_json AS jsonb)', null: false, default: '{}' 
    change_column :assets, :reclassification, 'jsonb USING CAST(reclassification AS jsonb)', null: false, default: '{}'
    change_column :services, :information, 'jsonb USING CAST(information AS jsonb)', null: false, default: '{}'    
  end
end
