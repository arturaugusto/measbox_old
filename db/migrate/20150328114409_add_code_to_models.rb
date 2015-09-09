class AddCodeToModels < ActiveRecord::Migration
  def change
    add_column :models, :code, :json
  end
end
