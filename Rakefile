require "bundler/gem_tasks"
require_relative "lib/fba_reconcile"

desc "Download current AZ info from all marketplaces and imports into database"
task :fba do
	%w(hive blank uk).each do |market|
		FBAReconcile.start(@type, market, true)
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
	sh "mkdir tmp" unless File.exist?("tmp")
	abort unless check_for_config
end

desc "Run FBA update"
task :update_fba_status, :type do |t, args|
	@type = args[:type]
	Rake::Task["start_logger"].invoke
	Rake::Task["setup"].invoke
	Rake::Task["fba"].invoke
end

desc "Start logger"
task :start_logger do
	@output_logfile, @error_logfile = File.join(Dir.pwd, "tmp/output.log"), File.join(Dir.pwd, "tmp/error.log")
	set_stdout
	rotate_logs
	$stdout = File.open(@output_logfile, "a+")
	$stderr = File.open(@error_logfile, "a+")
end

def check_for_config
	File.exists?("./config.yml")
end

def log_files
	files = []
	files << @output_logfile if File.exists?(@output_logfile)
	files << @error_logfile if File.exists?(@error_logfile)
end

def rotate_logs
	files = log_files
	files.each do |file|
		if File.size?(file).to_i > 2
			File.delete(file)
			Rake::Task["start_logger"].invoke
		end
	end
end

def set_stdout
	STDOUT.sync = true
	STDERR.sync = true
	$stdout, $stderr = STDOUT, STDERR
end
