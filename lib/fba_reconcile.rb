require 'tiny_tds'
require 'mws-rb'
require 'yaml'

require_relative 'fba_reconcile/tools'
require_relative 'fba_reconcile/process'
require_relative 'fba_reconcile/api'
require_relative 'fba_reconcile/fba'
require_relative 'fba_reconcile/database'
require_relative 'fba_reconcile/version'

# load config params
CFG = YAML::load_file(File.join(File.expand_path("./"), "config.yml"))

module FBAReconcile

	def self.start(report_type)
		FBA.new(report_type)
		process = Processor::Status.new(report_type)
		process.build
	rescue
		start(report_type)
	end

end
