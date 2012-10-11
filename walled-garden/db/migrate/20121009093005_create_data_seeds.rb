class CreateDataSeeds < ActiveRecord::Migration
  def change
    create_table :data_seeds do |t|
      t.integer     :subscriber_id
      t.integer		:ip_address_id
      t.string		:url
      t.string		:rip
      t.string		:browser 
      t.string		:browser_version
      t.string		:agent
      t.timestamps
    end
  end
end
