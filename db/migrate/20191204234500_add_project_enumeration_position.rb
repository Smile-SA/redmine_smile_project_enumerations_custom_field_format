class AddProjectEnumerationPosition < ActiveRecord::Migration[4.2]
  def self.up
    add_column :project_enumerations, :position, :integer
  end

  def self.down
    remove_column :project_enumerations, :position
  end
end
