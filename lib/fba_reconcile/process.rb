require 'csv'

class Processor

	def initialize
		@afn_inventory, @local_inventory = Hash.new, Hash.new
		open_file
		local_listings
		sync
	end

	def open_file
		CSV.foreach("afn.csv", headers: true, header_converters: :symbol) do |row|
			@afn_inventory.merge!(row[:sellersku] => row[:quantity_available].to_i)
		end
	end

	def local_listings
		results = Database.query
		results.each do |row|
			@local_inventory.merge!(row["LocalSKU"] => { "FBA" => row["FBA"], "Quantity" => row["QOH"] })
		end
	end

	def sync
		@afn_inventory.each_pair do |sku, qty|
			@sku = sku
			operate(qty)
		end
	end

	def operate(qty)
		qty.zero? ? update_sql("No") : update_sql("Yes")
	end

	def update_sql(value)
		Database.update(@sku, value) if check_current
	end

	def check_current
		begin
			currently = @local_inventory.fetch(@sku)
			currently["FBA"] == "Yes" ? true : false
		rescue KeyError
			return false
		end
	end

end
