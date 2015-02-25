class CreateWorkbenches < ActiveRecord::Migration
  def change
    create_table :workbenches, id: :uuid do |t|
    	t.uuid :service_id, null: false
    	t.uuid :asset_id, null: false
    	t.integer :position, :limit => 8
    end
  	add_index :workbenches, [:service_id, :asset_id]
  end
end
