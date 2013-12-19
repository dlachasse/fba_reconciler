module Tools

	def self.find(tree, object)
		eval(tree) if tree.is_a? String
		tree.each do |k, v|
			if k == object
				@output = v
			elsif v.is_a? Hash
				find(v, object)
			end
		end
		@output
	end

end
