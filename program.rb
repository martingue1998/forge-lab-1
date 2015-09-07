require_relative './utils/form'
require_relative './utils/io'
require_relative './classes/player'
require_relative './classes/team'
require_relative './classes/championship'
require_relative './classes/match'

class Program
	include IOTools
	@@teams = []
	@@players = []
	@@fixture = {}
	

	def initialize()

		#se crea el form para preguntar el nombre del campeonato.
		form = Form.new('Ingresa la información del campeonato',
						name_championship: 'Nombre del campeonato')
		#Se incializa la variable para que no de error en la condición del Until
		entered_championship = ''
		#Se verifica que no se ingresen espacios vacios
		until entered_championship.strip != ''
			form.ask_for(:name_championship)
			championship_entered_data = form.get_data()
			entered_championship = championship_entered_data[0]
		end

		players = [5, 7, 11]

		type = form.select_from_list('Ingresa de cuantos jugadores quieres que sean los equipos: ', players)

		#Se crea la instancia de championship con los valores ingresados por el usuario
		@@championship = Championship.new(entered_championship, type)
	end

	def championship_can_be_played()
		flag = false

		@@teams.each do |team|
			if @@championship.type != team.number_players
				flag = true
			end
		end
		if @@teams.size == 0
			'No hay equipos para disputar el campeonato'
		elsif @@teams.size.odd?
			'La cantidad de equipos disponibles debe ser par'
		elsif flag
			'Hay equipos que tienen menos de la cantidad de jugadores requeridos'

		end
	end

	def championship_start()
		flag = true
		@@teams.each_with_index do |team, x| 
			@@teams.each do |team1|		

				if @@fixture.has_key?("#{team1.name} vs #{team.name}")
						flag = false
					elsif @@fixture.has_key?("#{team.name} vs #{team1.name}")
						flag = false
					else
						flag = true
				end

				if team.name != team1.name && flag 
					match = Match.new(team.name, team1.name)
					@@fixture["#{team.name} vs #{team1.name}"] = match
				end	
			end
		end


		fixture = @@fixture.to_a
		fixture.shuffle!
		@@fixture = fixture.to_h
	end

	def championship_name()
		@@championship.name
	end


	def add_team()
		team = nil

		

		while !team
			#Se pide mediante form la información para ingresar un jugador
			form = Form.new('Ingrese nuevo equipo',
							name: 'Nombre: ')
			
			form.ask_for(:name)
			team_entered_data = form.get_data()

			exist_team = @@teams.find { |team| team.name == team_entered_data[0] }
			unless exist_team.nil?
				show_error('Ya hay un equipo con el nombre indicado')
			else
				#Se crea una instancia de team con los datos que se ingresaron antes.
				team = Team.new(team_entered_data[0])
			end
		end
		if @@teams.size == 16
			show_error('No se pueden ingresar mas de 16 equipos')
		else 
			@@teams << team 
		end
		
	end
	def add_player()
		player = nil

		while !player
			#Se pide mediante form la información para ingresar un jugador
			form = Form.new('Ingrese nuevo jugador', name_player: 'Nombre: ', ci: 'Cédula de Identidad: ')
			form.ask_for(:name_player, :ci)
			player_entered_data = form.get_data()

			exist_player = @@players.find { |player| player.ci == player_entered_data[1] }

			unless exist_player.nil?
				show_error('Ya hay un jugador con la ci indicada')
			else
				#Se crea una instancia de player con los datos que se ingresaron antes.
				player = Player.new(player_entered_data[0], player_entered_data[1])
			end
		end
		@@players << player 
		
	end

	def add_player_to_team()

		players_without_team = []

		@@players.each do |player| 

			if player.team.nil?
				players_without_team << player
			end
		end

		if !players_without_team.empty? && !@@teams.empty?
			#Se crea el form 
			form = Form.new('', teams: @@teams)

			#Se crea el array para guardar las opciones ya formateadas

			players_strings = []
			
			# Se carga en un array los jugadores con sus cedula ya formateado

			i = 0
			while i < players_without_team.size
				players_strings << "#{players_without_team[i].name} (#{players_without_team[i].ci})"
				i += 1
			end
			#Se pregunta el jugador que quiere ingresar y se pasa la lista de los jugadores al form
			#Se filtra el texto y se toma solo la cedula para poder identificarlo.
			selected_option_player = form.select_from_list('Que jugador desea agregar?', players_without_team.collect { |player| "#{player.name} (#{player.ci})"}).split()[1].gsub(/[^0-9]/, '')

			
		
			#Se pregunta por el equipo al cual quiere ingresar el jugador
			#Se usa .split que devuelve un array con cada palabra como un elemento, el lugar 0 es el que buscamos

			selected_option_team = nil

			while !selected_option_team
			
				selected_option_team = form.select_from_list('A que equipo?', @@teams.collect { |team| "#{team.name} (#{team.number_players} jugadores)"}).split()[0]
				
				@@teams.each do |team|
					if team.name == selected_option_team && team.number_players == @@championship.type
						show_error('El equipo elegido ya tiene el máximo de jugadores posibles')
						selected_option_team = nil	
					end
				end
			end

			@@players.each do |player| 
				if player.ci == selected_option_player
					player.team = selected_option_team
				end	
			end

			@@teams.each do |team| 
				if team.name == selected_option_team
					team.number_players += 1							
				end
			end
		elsif @@teams.empty?
			show_error('No hay equipos creados aun')
		elsif players_without_team.empty?
			show_error('No hay jugadores sin equipo')
		elsif @@players.empty?
			show_error('No hay jugadores ingresados')
		
		end
	end

	def display_players()


		if !@@players.empty?
			players = []
			i = 0
			while i < @@players.size
				players << "#{@@players[i].name} (#{@@players[i].ci})"
				i += 1
			end
			display_list(players)
		else
			show_error('No hay jugadores ingresados')
		end

		
	end


	def display_teams()
		if !@@teams.empty?
			teams = []
			i = 0
			while i < @@teams.size
				teams << "#{@@teams[i].name} (#{@@teams[i].number_players} jugadores)"
				i += 1
			end
			display_list(teams)
		else
			show_error('No hay equipos ingresados')
		end
	end

	def next_match()

		fixture_unplayed = {}

		@@fixture.each_pair do |string, match|
			unless match.played
				fixture_unplayed[string] = match
			end
		end
		if fixture_unplayed.empty?
			show_error('No hay mas partidos')
		else
			p fixture_unplayed.keys[0]
			
			@@fixture.each_value do |match|
				if match.team1 == fixture_unplayed.values[0].team1 && match.team2 == fixture_unplayed.values[0].team2
					match.score1 = get_input('Ingresa los goles del primer equipo:')
					match.score2 = get_input('Ingresa los goles del segundo equipo:')
					match.played = true

					if match.score1 < match.score2
						@@teams.each do |team|
							if team.name == match.team1
								team.pj += 1
								team.pp += 1
							elsif team.name == match.team2
								team.pj += 1
								team.pg += 1
								team.points += 3								
							end
						end
					elsif match.score1 > match.score2
						@@teams.each do |team|
							if team.name == match.team2
								team.pj += 1
								team.pp += 1
							elsif team.name == match.team1
								team.pj += 1
								team.pg += 1
								team.points += 3								
							end
						end	
					elsif match.score1 == match.score2
						@teams.each do |team|
							if team.name == match.team2
								team.pj += 1
								team.pe += 1
								team.points += 1
							elsif team.name == match.team1
								team.pj += 1
								team.pe += 1
								team.points += 1
							end
						end	
					end
				end			
			end
		end
	end

	def display_fixture()
		display_list(@@fixture.keys)
	end

	def display_team_players()


		unless @@teams.empty?
			#Se crea el form 
			form = Form.new('', @@teams)

			#Se pregunta por el equipo
			selected_option_team = form.select_from_list('De que equipo desea consultar los jugadores?', @@teams.collect {|team| "#{team.name} (#{team.number_players} jugadores)"}).split()[0]

			@@teams.each do |team|
				if team.name == selected_option_team && team.number_players != 0
					@@players.each do |player|
						if player.team == selected_option_team
							p "#{player.name} (#{player.ci})"
						end
					end
				elsif team.number_players == 0
					show_error('El equipo no tiene jugadores')
					
				end
			end
		else
			show_error('No hay equipos ingresados')
		end
	end


	def print_table()

		fixture = {}

		@@fixture.each_pair do |string, match|
			unless match.played
				fixture[string] = match
			end
		end

		if fixture.empty?
			points = 0
			winner = nil
			@@teams.each do |team|
				if team.points > points
					winner = team.name
				end
			end
			p "#{winner} ha ganado el campeonato"
			p 'Equipo | PJ | PG | PE | PP | Puntos'
			@@teams.each do |team|
				p "#{team.name}     |  #{team.pj} |  #{team.pg} |  #{team.pe} |  #{team.pp} |  #{team.points}"
			end	
		else
			p 'Equipo | PJ | PG | PE | PP | Puntos'
			@@teams.each do |team|
			p "#{team.name}     |  #{team.pj} |  #{team.pg} |  #{team.pe} |  #{team.pp} |  #{team.points}"
			end
		end
	end
end