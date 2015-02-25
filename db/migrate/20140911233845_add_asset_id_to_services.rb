class AddAssetIdToServices < ActiveRecord::Migration
  def change
    add_column :services, :asset_id, :uuid
  end
end
