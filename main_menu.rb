require 'singleton'

require_relative 'utils/io'
require_relative 'program'

class MainMenu
  include IOTools
  include Singleton

  EXIT = -1

  def initialize
    @backend = Program.new
  end

  def go_to_championship
    championship_problems = @backend.championship_can_be_played

    unless championship_problems
      @backend.championship_start
      championship_menu
    else
      show_error(championship_problems)
      run
    end
  end

  def championship_menu
    @last_action = :championship_menu

    until @last_action == EXIT  do
      actions = display_menu({
        @backend.championship_name => {
          'Ver Fixture' => :display_fixture,
          'Ingresar resultado próximo partido'  => :next_match,
          'Ver tabla de posiciones' => :print_table,
        },
        'Salir' => :exit
      })

      print '> '
      option = $stdin.gets.chomp

      action = actions[option.to_i]
      case action
      when nil
        show_error('Opción inválida')
      when :exit
        send(action)
      else
        @backend.send(action)
      end
    end
  end

  def exit
    @last_action = EXIT
  end

  def run
    @last_action = :run

    until @last_action == EXIT do
      actions = display_menu({
        'Ingresar Datos' => {
          'Agregar un nuevo jugador' => :add_player,
          'Agregar un nuevo equipo'  => :add_team,
          'Agregar jugador a equipo' => :add_player_to_team,
        },
        'Consultas' => {
          'Ver jugadores ingresados'   => :display_players,
          'Ver equipos ingresados'     => :display_teams,
          'Ver jugadores de un equipo' => :display_team_players
        },
        'Campeonato' => {
          'Comenzar campeonato con los equipos disponibles' => :go_to_championship
        },
        'Salir' => :exit
      })

      print '> '
      option = $stdin.gets.chomp

      action = actions[option.to_i]
      case action
      when nil
        show_error('Opción inválida')
      when :exit, :go_to_championship
        send(action)
      else
        @backend.send(action)
      end
    end
  end
end

MainMenu.instance.run
