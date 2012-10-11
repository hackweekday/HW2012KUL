class CreateDataSilos < ActiveRecord::Migration
  def change
    create_table :data_silos do |t|
      t.string 		:sid
      t.string		:url
      t.string		:rip
      t.string		:country
      t.string		:state
      t.string		:browser 
      t.string		:browser_version
      t.string		:agent
      t.timestamps
    end
  end
end
