require 'time'

require_relative './api'

class FBA
	include Connection
	include Request

	def initialize(mws)
		@mws = mws
		get_report_list
		check_for_recent_request
	end

	def check_for_recent_request
		last_report = extract_report_item("ReportType", "_GET_AFN_INVENTORY_DATA_")
		if recent_usable_report?
			@request_id = last_report["ReportRequestId"]
			@report_id = last_report["ReportId"]
			retrieve_report_output
		else
			request
		end
	end

	def recent_usable_report?
		time_at_last_report = Time.parse(last_report["AvailableDate"])
		(Time.now - time_at_last_report).to_i < 3600 ? true : false
	end

	def request
		@request_id = Request.request_report(@mws)
		p @request_id
		@report_list = get_report_list
		p @report_list
		@report_id = report_id
		p @report_id
		retrieve_report_output
	end

	def get_report_list
		@report_list = Request.retrieve_report_list(@mws)
	end

	def report_id
		extract_report_item("ReportRequestId", @request_id, "ReportId")
	end

	def acknowledged?
		output = extract_report_item("ReportRequestId", @request_id, "Acknowledged")
		p output
		to_bool(output)
	end

	# Extracts report values
	def extract_report_item(parameter, value, item=nil)
		@report_list.map { |report| report if report[] == value }.compact[0]
		item ? output[item] : output
	end

	def retrieve_report_output
		until acknowledged?
		  sleep(180)
		  p "Not acknowledged :: Recheck"
		  get_report_list
		end
		p Request.retrieve_report(@mws, @report_id)
	end

	def to_bool(str)
    return true if str =~ (/^(true|t|yes|y|1)$/i)
    return false if str =~ (/^(false|f|no|n|0)$/i) || str.nil?

    raise ArgumentError.new "invalid value: #{str}"
  end

end
