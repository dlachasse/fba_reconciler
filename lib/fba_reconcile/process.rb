require 'csv'

module Processor

	class Status

		def initialize(report_type)
			@report_type = report_type
			@file = File.join("./tmp/", @report_type + ".csv")
		end

		def build
			get_sku_column_name
			prep_table
			build_query_from_item_hash
			Database.merge_temp_and_stored_fba_table
		end

		def scan_headers
			File.open(@file, &:readline)
		end

		def get_sku_column_name
			row = scan_headers
			@sku = row.scan(/((?<=")sku|seller-sku|^sku)/).flatten[0]
		end

		def strip_trailing_comma data
			data.gsub(/,\z/, "")
		end

		def prep_table
			Database.create_temp_fba_table
		end

		def build_query_from_item_hash
			@afn_inventory = "INSERT INTO #tempFBA VALUES "
			CSV.foreach(@file, { :headers => true, :return_headers => false, :converters => :integer }) do |row|
				@afn_inventory += "('#{row[@sku]}',3,#{total_inbound(row["afn-inbound-shipped-quantity"], row["afn-inbound-working-quantity"], row["afn-inbound-receiving-quantity"])},#{row['afn-fulfillable-quantity']},#{row['afn-unsellable-quantity']},#{row['afn-reserved-quantity']}),"
			end
			query = strip_trailing_comma @afn_inventory
			Database.append_query query
		end

		def total_inbound shipped, working, receiving
			shipped + working + receiving
		end

	end

end
