class Team

	attr_accessor :name, :number_players, :pj, :pg, :pe, :pp, :points

	def initialize(name)
		@name = name
		@number_players = 0
		@pj = 0
		@pg = 0
		@pe = 0
		@pp = 0
		@points = 0
	end

end