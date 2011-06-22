class AddMaintenanceMode < ActiveRecord::Migration
  def self.up
    add_column :pods, :maintenance, :datetime
  end

  def self.down
    remove_column :pods, :maintenance
  end
end
