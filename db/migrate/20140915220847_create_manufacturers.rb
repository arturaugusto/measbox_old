class CreateManufacturers < ActiveRecord::Migration
  def change
    create_table :manufacturers, id: :uuid do |t|
      t.string :name
      t.uuid :laboratory_id
      t.timestamps
    end
    add_index :manufacturers, :laboratory_id
  end
end
