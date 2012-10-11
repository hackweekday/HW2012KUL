class CreatePictures < ActiveRecord::Migration
	def self.up
		create_table :pictures do |t|
			t.string :comment
			t.string :name
			t.string :content_type
			t.binary :picture
		end
	end

	def self.down
		drop_table :pictures
	end

end
