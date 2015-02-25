class ReportTemplate < ActiveRecord::Base
	has_many :reports
	default_scope { where(laboratory_id: Laboratory.current_id) }		
end
