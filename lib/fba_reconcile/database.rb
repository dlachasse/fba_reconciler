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
				SET Text1 = '#{fba}'
				WHERE LocalSKU = '#{sku}'"
			result = @client.execute sql
			result.do
			puts "UPDATED :: #{sku} to #{fba}"
		end

		def send_query query
			@client = self.connect
			puts "RUNNING: #{query}"
			result = @client.execute query
			result.do
		end

		def create_temp_fba_table
			@query = "CREATE TABLE #tempFBA(                                        
				[LocalSKU] [varchar](255) COLLATE Latin1_General_100_CI_AI NOT NULL,
				[CartID] [tinyint] NOT NULL,
				[Inbound] [smallint] NULL,
				[Fulfillable] [smallint] NULL,
				[Unfulfillable] [smallint] NULL,
				[Reserved] [smallint] NULL);"
		end

		def drop_temp_fba_table
			@query = "DROP TABLE #tempFBA"
			send_query query
		end

		def append_query query
			@query ||= ""
			@query << query
		end

		def merge_temp_and_stored_fba_table
			@query ||= ""
			@query << "
				MERGE [SE Data].[dbo].[FBA] AS TARGET
				USING #tempFBA AS SOURCE
				ON (TARGET.LocalSKU COLLATE Latin1_General_100_CI_AI = SOURCE.LocalSKU)
				WHEN MATCHED THEN UPDATE
					SET TARGET.LocalSKU = SOURCE.LocalSKU, TARGET.CartID = SOURCE.CartID, TARGET.Inbound = SOURCE.Inbound, TARGET.Fulfillable = SOURCE.Fulfillable, TARGET.Unfulfillable = SOURCE.Unfulfillable, TARGET.Reserved = SOURCE.Reserved                                WHEN NOT MATCHED BY TARGET THEN
				INSERT (LocalSKU, CartID, Inbound, Fulfillable, Unfulfillable, Reserved)
					VALUES (SOURCE.LocalSKU, SOURCE.CartID, SOURCE.Inbound, SOURCE.Fulfillable, SOURCE.Unfulfillable, SOURCE.Reserved)
				WHEN NOT MATCHED BY SOURCE THEN DELETE;"
			send_query @query
		end
		
	end

end
