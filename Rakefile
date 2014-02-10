require "bundler/gem_tasks"
require_relative "lib/fba_reconcile"

desc "Download current AZ info from all marketplaces and imports into database"
task :fba_status, :type do |t, args|
	type = args[:type]
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
