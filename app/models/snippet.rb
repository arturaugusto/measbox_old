class Snippet < ActiveRecord::Base
	acts_as_taggable
	acts_as_taggable_on :models, :functionalities
	default_scope { where(laboratory_id: Laboratory.current_id) }
    #length: { :in => 6..20 },
	#message: 'Erro!'
	#serialize :value, JSON
	#before_create do
	#	self.value ||= ""
	#end	
end
