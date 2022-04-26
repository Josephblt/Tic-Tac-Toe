# frozen_string_literal: true

# Defines and control Symbol Option selection
class SymbolOptions
  REGULAR = 0
  INVERTED = 1

  attr_reader :selected_option

  def initialize
    @selected_option = REGULAR
  end

  def next
    @selected_option += 1
    @selected_option %= 2
  end
end
