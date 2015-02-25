class AddCustomFormsToLaboratories < ActiveRecord::Migration
  def change
    add_column :laboratories, :custom_forms, :json
  end
end
