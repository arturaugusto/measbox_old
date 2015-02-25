class Asset < ActiveRecord::Base
	acts_as_taggable
	belongs_to :laboratory
	belongs_to :company
	belongs_to :model
	#has_and_belongs_to_many :services, join_table: :workbenches
	has_many :workbenches, -> { order("position ASC") }
	has_many :services, :through => :workbenches
	default_scope { where(laboratory_id: Laboratory.current_id) }
	attr_accessor :changeable
	attr_accessor :button_role
	attr_accessor :position
end
