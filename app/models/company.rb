class Company < ActiveRecord::Base
	has_many :users
	has_many :assets
	belongs_to :laboratory
	default_scope { where(laboratory_id: Laboratory.current_id) }
end
