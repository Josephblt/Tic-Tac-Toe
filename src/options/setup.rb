# frozen_string_literal: true

require_relative 'ai_options'
require_relative 'controller_options'
require_relative 'symbols_options'

# Class that holds all configurable game options.
class Setup
  attr_reader :ai1_option,
              :ai2_option,
              :controller1_option,
              :controller2_option,
              :symbol_option

  def initialize
    @ai1_option = AIOptions.new AIOptions::EASY
    @ai2_option = AIOptions.new AIOptions::EASY
    @controller1_option = ControllerOptions.new ControllerOptions::HUMAN
    @controller2_option = ControllerOptions.new ControllerOptions::ARTIFICIAL_INTELLIGENCE
    @symbol_option = SymbolOptions.new
  end

  def change_ai1_options
    @ai1_option.next
  end

  def change_ai2_options
    @ai2_option.next
  end

  def change_controller1_options
    @controller1_option.next
  end

  def change_controller2_options
    @controller2_option.next
  end

  def change_symbol_options
    @symbol_option.next
  end
end
