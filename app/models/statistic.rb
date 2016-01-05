class Statistic < ActiveRecord::Base
	def self.find_or_new_by(*args)
		data = Statistic.find_by(*args)
	unless data
		data = Statistic.new(*args)
	end
		data
	end

end