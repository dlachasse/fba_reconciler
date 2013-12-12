require_relative './api'

class FBA
	include Connection
	include Request

	def initialize()
		mws = Connection.connect("hive")
		request
	end

	def get_report_list
		@report_list = Request.retrieve_report_list
	end

	def request
		Request.request_report(mws)
		run_check
	end

	def report_id
		extract_report_item("ReportId")
	end

	def acknowledged?
		extract_report_item("Acknowledged")
	end

	# Extracts report values
	def extract_report_item(item)
		@report_list.map { |report| report[item] if report["ReportRequestId"] == @request_id }.compact[0]
	end

end
