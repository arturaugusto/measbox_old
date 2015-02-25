class CreateReportTemplates < ActiveRecord::Migration
  def change
    create_table :report_templates, id: :uuid do |t|
      t.string :name
      t.text :value
      t.uuid :laboratory_id
      t.timestamps
    end
    add_index :report_templates, :laboratory_id
  end
end
