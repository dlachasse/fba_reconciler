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

	def self.recs
		%w(Inventory Selection Pricing Fulfillment ListingQuality).each do |cat|
			recs = Request.new(:connect, variable: "@recommendation_category", value: cat)
			data = recs.request_recommendations
			f = File.new("./recommendations_#{cat.downcase}.txt", "w+")
			f.puts data.to_xml(root: 'ListRecommendationsResult')
		end
	end

	def self.start
		FBA.new unless FBA.recent_report_downloaded?
		Processor.new
	end

end
