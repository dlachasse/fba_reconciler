require 'time'

require_relative './api'

class FBA

	attr_accessor :mws

	def initialize
		start_connection
		get_report_list
		check_for_recent_request
	end

	def start_connection
		connection = Request.new(:connect)
		@@mws = connection.mws
	end

	def check_for_recent_request
		last_report = extract_report_item("ReportType", "_GET_AFN_INVENTORY_DATA_")
		if last_report.nil?
			request
		elsif useable_report? last_report
			@request_id = last_report["ReportRequestId"]
			@report_id = last_report["ReportId"]
			retreive_report
		else
			request
		end
	end

	def useable_report? report
		time_at_last_report = Time.parse(report["AvailableDate"]).utc
		(Time.now.utc - time_at_last_report).to_i < 2700 ? true : false
	end

	def request
		request = Request.new(:request_report)
		@request_id = request.request_id
		@report_list = get_report_list
		@report_id = report_id
		puts "Report generated:
			REQUEST_ID: #{@request_id}
			REPORT_ID: #{@report_id}"
		wait_til_usable_report
	end

	def get_report_list
		request = Request.new(:retrieve_report_list)
		@report_list = request.report_list
	end

	def report_id
		extract_report_item("ReportRequestId", @request_id, "ReportId")
	end

	# Extracts report values
	def extract_report_item(parameter, value, item=nil)
		output = @report_list.map { |report| report if report[parameter] == value }.compact[0]
		puts "Extracting #{parameter} returned: #{output}"
		item.nil? ? output : output[item]
	rescue NoMethodError
		puts "No object was returned"
	end

	def wait_til_usable_report
		until useable_report?
		  p "Not ready :: Recheck"
		  sleep(180)
		  get_report_list
		end
		retreive_report
	end

  def retreive_report
  	request = Request.new(:retrieve_report, { variable: "@report_id", value: @report_id })
		write_out_file(request.report.parsed_response)
	end

	def format_data(data)
		data.gsub!("\r\n", "\n").gsub!("\t", ",")
	end

	def write_out_file(data)
		data = format_data(data)
		output = File.open("afn.csv", "w+")
		output.puts data
	end

	def self.recent_report_downloaded?
		(Time.now.utc - File.mtime(File.join(File.expand_path("./lib/"), 'afn.csv')).utc).to_i < 2700
	end

end
