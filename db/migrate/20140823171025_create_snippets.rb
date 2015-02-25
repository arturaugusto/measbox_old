class CreateSnippets < ActiveRecord::Migration
  def change
    create_table :snippets, id: :uuid do |t|
    	t.integer :flavor
    	t.json :value
    	t.boolean :validated
    	t.uuid :laboratory_id
      t.timestamps
    end
    add_index :snippets, :laboratory_id
  end
end
