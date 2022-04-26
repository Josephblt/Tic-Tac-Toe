# frozen_string_literal: true

# Defines and control AI Option selection
class AIOptions
  EASY = 0
  HARD = 1
  IMPOSSIBLE = 2

  attr_reader :selected_option

  def initialize(option)
    @selected_option = option
  end

  def next
    @selected_option += 1
    @selected_option %= 3
  end
end
