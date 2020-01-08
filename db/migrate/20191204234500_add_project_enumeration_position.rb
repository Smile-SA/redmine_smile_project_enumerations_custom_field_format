if Redmine::VERSION::MAJOR < 4
  migration = ActiveRecord::Migration
else
  migration = ActiveRecord::Migration[4.2]
end

class AddProjectEnumerationPosition < migration
  def self.up
    add_column :project_enumerations, :position, :integer
  end

  def self.down
    remove_column :project_enumerations, :position
  end
end
