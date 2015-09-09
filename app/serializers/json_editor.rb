class JsonEditor
  def self.dump(hash)
    hash
  end

  def self.load(hash)
    (hash || {}).to_json
  end
end
