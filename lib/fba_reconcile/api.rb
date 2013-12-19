require 'mws-rb'

class Request

	include Tools
	attr_accessor :mws

	def initialize(market, method)
		puts "Connecting to Amazon MWS"
		@mws = MWS.new(
		  host: CFG["#{market}"]["host"],
		  aws_access_key_id: CFG["#{market}"]["aws_access_key_id"],
		  aws_secret_access_key: CFG["#{market}"]["aws_secret_access_key"],
		  seller_id: CFG["#{market}"]["seller_id"]
		)
		send(method)
	end

	# Returns id of request for later use
	def request_report
		puts @mws
		response = @mws.reports.request_report("ReportType" => "_GET_AFN_INVENTORY_DATA_").parsed_response
		@request_id = Tools.find(response, "ReportRequestId")
	end

	# Checks status of report with request id generated in previous request
	def retrieve_report_list
		puts @mws
		status = @mws.reports.get_report_list.parsed_response
		report_list = Tools.find(status, "ReportInfo")
	end

	def retrieve_report(report_id)
		puts @mws
		@mws.reports.request_report("ReportId" => report_id)
	end

end


