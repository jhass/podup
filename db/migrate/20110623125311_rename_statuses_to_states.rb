class RenameStatusesToStates < ActiveRecord::Migration
  def self.up
    rename_table :statuses, :states
  end

  def self.down
    rename_table :states, :statuses
  end
end
