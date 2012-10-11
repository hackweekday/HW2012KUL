class ResearchController < ApplicationController
	def index
		#Resque.enqueue(ResearchApplication, "test.my")
		Dnscell::Email.test_email("amir@localhost.my").deliver
		render :text => "hackerspace"
	end

	def show
		#Resque.enqueue(ResearchApplication, "amir.com", "nama.amir.com", "1.1.1.1")
		#Resque.enqueue(CreateZoneApplication, "amir.com")
		render :text => "Add A resource record"
	end
end
