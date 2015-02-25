class AddModelIdToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :model_id, :uuid
  end
end
