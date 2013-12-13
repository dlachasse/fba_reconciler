require 'mws-rb'

module Connection

	def self.connect(market)
		puts "Connecting to Amazon MWS"
		mws_api = MWS.new(
		  host: CFG["#{market}"]["host"],
		  aws_access_key_id: CFG["#{market}"]["aws_access_key_id"],
		  aws_secret_access_key: CFG["#{market}"]["aws_secret_access_key"],
		  seller_id: CFG["#{market}"]["seller_id"]
		)
	end

end

module Request

	# Returns id of request for later use
	def self.request_report(mws)
		response = mws.reports.request_report("ReportType" => "_GET_AFN_INVENTORY_DATA_").parsed_response
		@request_id = Tools.find(response, "ReportRequestId")
	end

	# Checks status of report with request id generated in previous request
	def self.retrieve_report_list(mws)
		status = mws.reports.get_report_list.parsed_response
		report_list = Tools.find(status, "ReportInfo")
	end

	def self.retrieve_report(mws, report_id)
		mws.reports.request_report("ReportId" => report_id)
	end

end

module Tools

	def self.find(tree, object)
		eval(tree) if tree.is_a? String
		tree.each do |k, v|
			if k == object
				@output = v
			elsif v.is_a? Hash
				find(v, object)
			end
		end
		@output
	end

end
