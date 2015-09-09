class Spreadsheet < ActiveRecord::Base
	acts_as_taggable
  belongs_to :service
	default_scope { where(laboratory_id: Laboratory.current_id) }
  #serialize :table_json, JSON
  #before_create do
  # self.table_json ||= {}
  #end  

end

