#sudo apt-get install postgresql-contrib
ActiveRecord::Base.connection.execute('CREATE EXTENSION "uuid-ossp"')
class CreateLaboratories < ActiveRecord::Migration
  def change
    create_table :laboratories, id: :uuid do |t|
      t.string :name
      t.string :subdomain

      t.timestamps
    end
  end
end
