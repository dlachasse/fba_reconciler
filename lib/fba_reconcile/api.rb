require 'mws-rb'

class Request

	include Tools
	attr_accessor :mws, :request_id, :report_list, :report

	def initialize(method,opts={})
		@opts = opts
		@market = @opts[:market] if @opts[:market]
		send(method)
	end

	def connect
		@@mws = MWS.new(
		  host: CFG[@market]["host"],
		  aws_access_key_id: CFG[@market]["aws_access_key_id"],
		  aws_secret_access_key: CFG[@market]["aws_secret_access_key"],
		  seller_id: CFG[@market]["seller_id"]
		)
		raise MarketplaceNotFound if !@market
	end

	# Returns id of request for later use
	def request_report
		opts = set_opts
		response = @@mws.reports.request_report(opts).parsed_response
		@request_id = Tools.find(response, "ReportRequestId")
	end

	def set_opts
		opts = Hash.new
		opts.merge!("MarketplaceIdList.Id.1" => CFG[@market]["marketplace_id"]) unless CFG[@market].nil?
		opts.merge!("ReportType" => @opts[:report_type]) unless @opts[:report_type].nil?
	end

	# Checks status of report with request id generated in previous request
	def retrieve_report_list
		status = @@mws.reports.get_report_list.parsed_response
		@report_list = Tools.find(status, "ReportInfo")
	end

	def retrieve_report
		@report = @@mws.reports.get_report("ReportId" => @opts[:report_id])
	end

	def request_recommendations
		@@mws.recommendations.list_recommendations("MarketplaceId" => CFG[@opts[:market]]["marketplace_id"], "RecommendationCategory" => @opts[:recommendation_category]).parsed_response
	end

end


