class AddMaintenanceToStates < ActiveRecord::Migration
  def self.up
    add_column :states, :maintenance, :boolean, :default => false
  end

  def self.down
    remove_column :states, :maintenance
  end
end
