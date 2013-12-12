require_relative './api'

class FBA
	include Connection
	include Request

	def initialize()
		mws = Connection.connect("hive")
		Request.request_report(mws)
	end

end
