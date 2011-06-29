class AddUpsinceToPods < ActiveRecord::Migration
  def self.up
    add_column :pods, :upsince, :datetime
  end

  def self.down
    remove_column :pods, :upsince
  end
end
