class RpzUtils
	
	RPZ_SERVER = "198.61.201.149" #Praise.go.my
	#This is a note for utils.
	#NS UPdate is possible dude.
	def self.port_test(ip = "127.0.0.1", port = 953)
      #Dnscell::Utils.port_test()
      begin
        Timeout::timeout(1) do
          begin
            s = TCPSocket.new(ip, port)
            s.close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
            return false
          end
        end
      rescue Timeout::Error
        return false
      end
      return false
  	end
	
	def self.create_rpz_zone

	end

	def self.create_rpz_record

	end

	def self.destroy_rpz_record

	end

	def self.hello
		puts "how are you dude"
	end
end