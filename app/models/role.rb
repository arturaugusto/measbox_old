class Role < ActiveRecord::Base
  include TheRole::Role
  
  default_scope { where(laboratory_id: Laboratory.current_id) }
end
