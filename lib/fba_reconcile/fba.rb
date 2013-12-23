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
		elsif recent_usable_report? last_report
			@request_id = last_report["ReportRequestId"]
			@report_id = last_report["ReportId"]
			retreive_report
		else
			request
		end
	end

	def recent_usable_report? last_report
		puts "Last Report returning: #{last_report}"
		time_at_last_report = Time.parse(last_report["AvailableDate"]).utc
		(Time.now.utc - time_at_last_report).to_i < 2700 ? true : false
	end

	def request
		request = Request.new(:request_report)
		@request_id = request.request_id
		@report_list = get_report_list
		@report_id = report_id
		wait_til_acknowledged
	end

	def get_report_list
		request = Request.new(:retrieve_report_list)
		@report_list = request.report_list
	end

	def report_id
		extract_report_item("ReportRequestId", @request_id, "ReportId")
	end

	def acknowledged?
		output = extract_report_item("ReportRequestId", @request_id, "Acknowledged")
		Time.now.utc > Time.parse(output).utc ? true : false
	end

	# Extracts report values
	def extract_report_item(parameter, value, item=nil)
		output = @report_list.map { |report| report if report[parameter] == value }.compact[0]
		puts "Extracting #{parameter} returned: #{output}"
		item ? output[item] : output
	rescue NoMethodError
		puts "No object was sent"
	end

	def wait_til_acknowledged
		until acknowledged?
		  p "Not acknowledged :: Recheck"
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
		(Time.now.utc - File.mtime('afn.csv').utc).to_i < 2700
	end

end
