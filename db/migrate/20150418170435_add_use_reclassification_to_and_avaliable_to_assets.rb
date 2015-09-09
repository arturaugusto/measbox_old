class AddUseReclassificationToAndAvaliableToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :use_reclassification, :boolean
    add_column :assets, :avaliable, :boolean
  end
end
