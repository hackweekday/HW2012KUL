class CreateSubscribers < ActiveRecord::Migration
  def change
    create_table :subscribers do |t|
      t.string 		:sid
      t.boolean		:status, :default => true
      t.timestamps
    end
  end
end
