if Redmine::VERSION::MAJOR < 4
  migration = ActiveRecord::Migration
else
  migration = ActiveRecord::Migration[4.2]
end

class CreateProjectEnumerations < migration
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
