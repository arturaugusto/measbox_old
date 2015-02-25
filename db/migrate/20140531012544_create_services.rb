class CreateServices < ActiveRecord::Migration
  def change

    create_table :services, id: :uuid do |t|
      t.string :order_number
      t.text :details
      t.uuid :laboratory_id
      t.uuid :user_id
      t.boolean :validated
      t.timestamps
    end
    add_index :services, :laboratory_id
  end
end
