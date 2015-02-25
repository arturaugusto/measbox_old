class CreateKinds < ActiveRecord::Migration
  def change
    create_table :kinds, id: :uuid do |t|
      t.string :name
      t.uuid :laboratory_id
      t.timestamps
    end
    add_index :kinds, :laboratory_id
  end
end
