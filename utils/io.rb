module IOTools
  def get_input(description)
    puts description
    print '> '
    $stdin.gets.chomp
  end

  def show_error(error)
    puts '========== ERROR: '
    puts error
    puts '=================='
  end

  def display_menu(menu_options)
    puts ''
    puts 'Elige una opción:'
    puts ''

    acc_index = 0
    indexed_actions = []

    menu_options.each do |k, v|
      if v.is_a?(Hash)
        puts "#{k}: "

        v.each do |option, action|
          puts "  #{acc_index += 1}. #{option}"

          indexed_actions[acc_index] = action
        end

        puts ''
      else
        puts "  #{acc_index += 1}. #{k}"

        indexed_actions[acc_index] = v
      end
    end

    indexed_actions
  end

  def display_list(list, options = {})
    
    puts options[:text] if options[:text]

    list.each_with_index do |el, index|
      if options[:ordered]
        puts "  #{index + 1}. #{el}"
      else
        puts "  * #{el}"
      end
    end
  end
end
