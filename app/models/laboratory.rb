class Laboratory < ActiveRecord::Base
	has_many :users
	has_many :companies
	has_many :roles
	cattr_accessor :current_id
	extend DeviseOverrides
	validates_uniqueness_of :subdomain
	validates :name,
		presence: true,
		length: { :in => 3..30, message: 'Laboratory name must have 3 to 30 characters.' }
	validates :subdomain,
		presence: true,
		format: { with: /\A[a-z0-9]+\z/, :message => 'Subdomain must be lowercase.' },
		length: { :in => 2..15, :message => 'Subdomain must have 2 to 15 characters.' }
end
