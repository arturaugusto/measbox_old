# This migration comes from the_role_engine (originally 20111025025129)
class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles, id: :uuid do |t| # uuid
      t.uuid :laboratory_id # multi tenacy
      t.string :name,        :null => false
      t.string :title,       :null => false
      t.text   :description, :null => false
      #Use Postgresql's native json
      #Remove this test if you using PostgreSQL prior to 9.2
      if   ::ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
        t.json :the_role, :null => false
      else
        t.text :the_role, :null => false
      end
      t.timestamps
    end
    add_index :roles, :laboratory_id # multi tenacy
  end

  def self.down
    drop_table :roles
  end
end