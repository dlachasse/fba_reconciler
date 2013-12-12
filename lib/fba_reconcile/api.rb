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
	def self.request_report(mws_api)
		@mws_api = mws_api
		response = mws_api.reports.request_report("ReportType" => "_GET_AFN_INVENTORY_DATA_").parsed_response
		@request_id = Tools.find(response, "ReportRequestId")
		puts response_id
		check_report_status
	end

	# Checks status of report with request id generated in previous request
	def self.check_report_status
		status = @mws_api.reports.get_report_list.parsed_response
		report_list = Tools.find(status, "ReportInfo")
		puts report_list
		@report_id = extract_report_id(report_list)
	end

	# Extracts report ID
	def self.extract_report_id(report_list)
		report_list.map { |report| report["ReportId"] if report["ReportRequestId"] == @request_id }.compact[0]
	end

	def self.retrieve_report(request_id)
		report_id = check_report(request_id)
		report = @mws_api.reports.request_report("ReportId" => report_id)
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
