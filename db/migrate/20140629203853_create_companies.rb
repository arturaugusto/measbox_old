class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies, id: :uuid do |t|
      t.string :name
      t.text :address
      t.text :details
      t.uuid :laboratory_id
      t.timestamps
    end
    add_index :companies, :laboratory_id
  end
end
