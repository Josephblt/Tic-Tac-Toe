# frozen_string_literal: true

# Defines and control Versus Option selection
class ControllerOptions
  HUMAN = 0
  ARTIFICIAL_INTELLIGENCE = 1

  attr_reader :selected_option

  def initialize(option)
    @selected_option = option
  end

  def next
    @selected_option += 1
    @selected_option %= 2
  end
end
