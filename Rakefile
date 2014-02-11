require "bundler/gem_tasks"
require_relative "lib/fba_reconcile"

desc "Download current AZ info from all marketplaces and imports into database"
task :fba, :type do |t, args|
	%w(hive blank uk).each do |market|
		FBAReconcile.start(type, market, true)
	end
end

desc "Download report for specified marketplace"
task :download_report, :type, :market do |t, args|
	FBAReconcile.start(args[:type], args[:market])
end

desc "Get recs"
task :recs do
	FBA.download_recommendations
end

desc "Setup project directory"
task :setup do
	sh "mkdir tmp"
	abort unless check_for_config
end

desc "Run FBA update"
task :update_fba_status, :type do |t, args|
	Rake::Task["start_logger"].invoke
	Rake::Task["setup"].invoke
	Rake::Task["fba"].invoke type: args[:type]
end

desc "Start logger"
task :start_logger do
	rotate_logs
	$stdout = File.open(File.join("./tmp/", "output.log"), "a+")
end

def check_for_config
	File.exist?("./config.yml")
end

def rotate_logs
	output_path = File.join("./tmp/", "output.log")
	if File.size?(output_path).to_i > 2
		File.delete(output_path)
		start_logger
	end
end
