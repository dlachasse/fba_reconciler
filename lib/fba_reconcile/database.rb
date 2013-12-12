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

		# sql = "SELECT inv.LocalSKU, sup.Cost, inv.Text1, inv.Price
		# FROM [SE Data].[dbo].[Inventory] AS inv
		# INNER JOIN [SE Data].[dbo].[InventorySuppliers] AS sup
		# ON inv.LocalSKU = sup.LocalSKU
		# 	WHERE inv.Category = 'Licensed Shirts'
		# 	AND inv.LocalSKU NOT LIKE 'RJ%'
		# 	And inv.QOH > 0
		# 	AND (sup.Cost IS NOT NULL OR sup.Cost <> 0)"
		# split @params[:client].execute sql
