class AddPdfOptionsToReportTemplates < ActiveRecord::Migration
  def change
    add_column :report_templates, :pdf_options, :json
  end
end
