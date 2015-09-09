class AddValueHtmlToReports < ActiveRecord::Migration
  def change
    add_column :reports, :value_html, :text
  end
end
