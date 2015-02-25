class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets, id: :uuid do |t|
      t.string :serial
      t.uuid :company_id
      t.string :identification
      t.string :certificate
      t.datetime :calibration_date
      t.datetime :due_date
      t.uuid :laboratory_id
      t.string :visa_address

      t.timestamps
    end
    add_index :assets, :laboratory_id
  end
end
