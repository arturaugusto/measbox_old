class Model < ActiveRecord::Base
	acts_as_taggable
	acts_as_taggable_on :models
	belongs_to :kind
	belongs_to :manufacturer
	has_many :assets
	default_scope { where(laboratory_id: Laboratory.current_id) }	
end
