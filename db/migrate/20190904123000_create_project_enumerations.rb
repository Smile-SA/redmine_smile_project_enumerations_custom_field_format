class CreateProjectEnumerations < ActiveRecord::Migration[4.2]
  def change
    create_table :project_enumerations do |t|
      t.integer :project_id, :null => false
      t.integer :custom_field_id, :null => false
      t.string :value
      t.string :status, :default => 'open'
      t.string :sharing, :default => 'none', :null => false
    end
  end
end
