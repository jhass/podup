class RemoveDefaultOnStateModel < ActiveRecord::Migration
  def self.up
    change_column :states, :up, :boolean, :default => nil
    change_column :states, :maintenance, :boolean, :default => nil
  end

  def self.down
    change_column :states, :up, :boolean, :default => false
    change_column :states, :maintenance, :boolean, :default => false
  end
end
