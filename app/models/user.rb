class User < ActiveRecord::Base
  #attr_reader :raw_invitation_token
  include TheRole::Api::User
  belongs_to :laboratory
  belongs_to :company
  has_many :services
  default_scope { where(laboratory_id: Laboratory.current_id) }
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # Disabled :validatable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :confirmable
  validates :email, 
    uniqueness: { scope: :laboratory_id, case_sensitive: false },
    presence: true
  validates :laboratory_id,
    presence: true
  validates :password,
    presence: true,
    length: { :in => 6..20 },
    :if => :password_required?
  validates_confirmation_of :email, :password,
                              message: 'should match.'
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end  
  #class DeviseController < Devise.parent_controller.constantize
  #  set_current_laboratory_by_subdomain(:laboratory_id, :subdomain)
  #end
  #validates_uniqueness_of :email, scope: :laboratory_id
  #protected
    # copied from validatable module
end
