class Role < ActiveRecord::Base
  include TheRole::Api::Role

  def _jsonable val
    val.is_a?(Hash) ? val : JSON.load(val)
  end

  def to_hash
    begin the_role rescue {} end
  end

  def to_json
    the_role.is_a?(Hash) ? the_role.to_json : the_role
  end
  
  default_scope { where(laboratory_id: Laboratory.current_id) }

end
