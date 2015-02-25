class Report < ActiveRecord::Base
	belongs_to :service
	belongs_to :report_template
	default_scope { where(laboratory_id: Laboratory.current_id) }	
end
