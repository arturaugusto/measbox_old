class AddCompanyIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :company_id, :uuid
  end
end
