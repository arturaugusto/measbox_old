class Manufacturer < ActiveRecord::Base
	has_many :models
	default_scope { where(laboratory_id: Laboratory.current_id) }	
end
