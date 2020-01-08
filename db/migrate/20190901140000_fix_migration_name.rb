if Redmine::VERSION::MAJOR < 4
  migration = ActiveRecord::Migration
else
  migration = ActiveRecord::Migration[4.2]
end

class FixMigrationName < migration
  def self.up
    execute "update schema_migrations set version='20190904123000-redmine_smile_project_enumerations_custom_field_format' where version='201909041230000-redmine_smile_project_enumerations_custom_field_format'"
  end

  def self.down
  end
end
