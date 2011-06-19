class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.integer :pod_id
      t.boolean :up, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :statuses
  end
end
