class CreateModels < ActiveRecord::Migration
  def change
    create_table :models, id: :uuid do |t|
      t.string :name
      t.uuid :manufacturer_id
      t.uuid :kind_id
      t.uuid :laboratory_id
      t.timestamps
    end
    add_index :models, :laboratory_id
  end
end
