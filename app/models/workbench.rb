class Workbench < ActiveRecord::Base
	acts_as_list scope: :service
	belongs_to :asset
	belongs_to :service
end
