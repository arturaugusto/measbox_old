class AddInformationToServices < ActiveRecord::Migration
  def change
    add_column :services, :information, :json
  end
end
