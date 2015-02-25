class AddNameAndTitleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :title, :string
  end
end
