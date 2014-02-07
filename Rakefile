require "bundler/gem_tasks"
require_relative "lib/fba_reconcile"

desc "Start reconciler"
task :start, :type do |t, args|
	type = args[:type]

	FBAReconcile.start(type)
end

desc "Get recs"
task :recs do
	FBAReconcile.recs
end
