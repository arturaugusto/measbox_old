class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports, id: :uuid do |t|
      t.string :name
      t.text :value
      t.uuid :service_id
      t.uuid :laboratory_id
      t.uuid :report_template_id
      t.timestamps
    end
    add_index :reports, :laboratory_id
  end
end
