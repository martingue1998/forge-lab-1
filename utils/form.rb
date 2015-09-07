require_relative 'io'

class Form
  include IOTools

  # El form se construye pasándole los posibles campos. Esto es 'attr' => 'texto'
  # Se piden de manera ordenada, es decir, el primer par clave-valor del hash
  # y sucesivamente
  #
  def initialize(title = '', fields = {})
    @fields = fields
    @saved_results = {}

    puts title unless title.strip.empty?
  end

  def select_from_list(selection_text, list)
    selected_option = nil

    until selected_option do
      puts selection_text
      display_list(list, ordered: true)
      index = get_input('')

      selected_option = list[(index.to_i - 1)]
      show_error('Opción inválida') unless selected_option
    end

    selected_option
  end

  def ask_for(*attrs)
    attrs.each do |attr|
      value = ''
      until value != ''
        value = get_input(@fields[attr])
        show_error('Es obligatorio ingresar un valor') if value == ''
      end
      @saved_results[attr] = value
    end
  end

  def get_data
    @saved_results.values
  end
end
