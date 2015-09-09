class AddPdfOptionsToReports < ActiveRecord::Migration
  def change
    add_column :reports, :pdf_options, :json
  end
end
