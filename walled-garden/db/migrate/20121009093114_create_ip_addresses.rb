class CreateIpAddresses < ActiveRecord::Migration
  def change
    create_table :ip_addresses do |t|
      t.string		:address
      t.string		:country
      t.string		:stateprov
      t.string		:city
      t.string		:latitude
      t.string		:longitude
      t.string		:tz_offset
      t.string		:tz_name
      t.string		:isp
      t.string		:ctype
      t.string		:organization
      t.timestamps
    end
  end
end
