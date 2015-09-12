class Service < ActiveRecord::Base
	has_many :reports, dependent: :destroy
	has_many :spreadsheets, dependent: :destroy
	#has_and_belongs_to_many :assets, join_table: :workbenches, primary_key: :id
	has_many :workbenches, -> { order "position"}, dependent: :destroy
	has_many :assets, :through => :workbenches
	belongs_to :user
	validates_presence_of :order_number
	default_scope { where(laboratory_id: Laboratory.current_id) }
	accepts_nested_attributes_for :assets, allow_destroy: true
end
