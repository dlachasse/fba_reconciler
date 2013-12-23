class Database

	class << self
		def connect
			client = TinyTds::Client.new(
				:host => CFG["server"]["host"], 
				:port => CFG["server"]["port"], 
				:username => CFG["server"]["username"], 
				:password => CFG["server"]["password"],
				:timeout => CFG["server"]["timeout"],
				:tds_version => CFG["server"]["tds_version"])
		end

		def query
			@client = connect
			sql = "SELECT LocalSKU, Text1 AS FBA, QOH
			FROM [SE Data].[dbo].[Inventory]
				WHERE Category = 'Licensed Shirts'"
			@client.execute sql
		end

		def update(sku, fba)
			@client = connect
			sql = "UPDATE [SE Data].[dbo].[Inventory]
				SET Text1 = #{fba}
				WHERE LocalSKU = #{sku}"
			result = @client.execute sql
			result.do
			puts "UPDATED :: #{sku} to #{fba}"
		end
	end

end
