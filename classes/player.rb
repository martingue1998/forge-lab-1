class Player

attr_accessor :ci, :name, :team

	def initialize(name, ci)
		@name = name
		@ci = ci
		@team = nil
	end
end