require "bundler/gem_tasks"
require_relative "lib/fba_reconcile"

desc "Start reconciler"
task :start, :type do |t, args|
	type = args[:type]
	%w(hive blank uk).each do |market|
		FBAReconcile.start(type, market)
	end
end

desc "Get recs"
task :recs do
	FBA.download_recommendations
end
