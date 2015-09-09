class Snippet < ActiveRecord::Base
	acts_as_taggable
	acts_as_taggable_on :models, :functionalities
	default_scope { where(laboratory_id: Laboratory.current_id) }
end
