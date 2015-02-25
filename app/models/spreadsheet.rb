class Spreadsheet < ActiveRecord::Base
	belongs_to :service
	acts_as_taggable
	default_scope { where(laboratory_id: Laboratory.current_id) }
	#serialize :table_json, JSON
	#before_create do
	#	self.table_json ||= {}
	#end	
end
