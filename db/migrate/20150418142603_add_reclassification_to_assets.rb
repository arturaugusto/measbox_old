class AddReclassificationToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :reclassification, :json
  end
end
