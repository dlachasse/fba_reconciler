class Database

	def self.connect
		client = TinyTds::Client.new(
			:host => CFG["server"]["host"], 
			:port => CFG["server"]["port"], 
			:username => CFG["server"]["username"], 
			:password => CFG["server"]["password"],
			:timeout => CFG["server"]["timeout"],
			:tds_version => CFG["server"]["tds_version"])
	end

	def self.query

	end

end
