require 'time'

require_relative './api'

class FBA

	attr_accessor :mws

	def initialize(report_type)
		@report_type = report_type
		start_connection
		get_report_list
		check_for_recent_request
	end

	def start_connection
		connection = Request.new(:connect)
		@@mws = connection.mws
	end

	def check_for_recent_request
		get_last_report
		if @last_report.nil?
			request
		elsif useable_report? @last_report
			@request_id = @last_report["ReportRequestId"]
			@report_id = @last_report["ReportId"]
			retreive_report
		else
			request
		end
	end

	def get_last_report
		@last_report = extract_report_item("ReportType", @report_type)
	end

	def useable_report? report
		return false if report.nil?
		time_at_last_report = Time.parse(report["AvailableDate"]).utc
		(Time.now.utc - time_at_last_report).to_i < 2700 ? true : false
	end

	def request
		request = Request.new(:request_report, { report_type: @report_type} )
		@request_id = request.request_id
		@report_list = get_report_list
		@report_id = report_id
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
		until useable_report? get_last_report
		  p "Not ready :: Recheck"
		  sleep(180)
		  get_report_list
		end
		retreive_report
	end

  def retreive_report
  	request = Request.new(:retrieve_report, { report_id: @report_id } )
		write_out_file(request.report.parsed_response)
	end

	def format_data(data)
		data.gsub!("\r\n", "\n").gsub!("\t", ",")
	end

	def write_out_file(data)
		data = format_data(data)
		output = File.open(File.join(File.expand_path("./tmp/"), @report_type + ".csv"), "w+")
		output.puts data
	end

	def self.recent_report_downloaded?
		(Time.now.utc - File.mtime(File.join(File.expand_path("./lib/"), @report_type + '.csv')).utc).to_i < 2700
	end

end
