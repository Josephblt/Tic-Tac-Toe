# frozen_string_literal: true

require_relative 'options/setup'
require_relative 'states/game_state'
require_relative 'states/goodbye_state'
require_relative 'states/continue_state'
require_relative 'states/over_state'
require_relative 'states/logo_state'
require_relative 'states/setup_state'
require_relative 'states/in_game_state'

# Simple implementation of the famous Tic-Tac-Toe game.
class Game
  attr_reader :board,
              :setup

  def initialize(display, input)
    @display = display
    @input = input
    @running = false
    @setup = Setup.new
    initialize_game_states
  end

  def change_to_state(state)
    @current_game_state&.exit
    @current_game_state = @game_states[state]
    @current_game_state&.enter
  end

  def play
    change_to_state LogoState
    @running = true

    while @running
      @current_game_state.update
      @display.renderers[@current_game_state.class].draw(@current_game_state)
      @display.refresh
    end

    @display.finalize
  end

  def reset
    @board = if @setup.symbol_option.selected_option == SymbolOptions::REGULAR
               Board.new(Symbol::CROSS, Symbol::NOUGHT)
             else
               Board.new(Symbol::NOUGHT, Symbol::CROSS)
             end
  end

  def quit
    @running = false
  end

  private

  def initialize_game_states
    @game_states = {}
    @game_states[ContinueState] = ContinueState.new(self, @input)
    @game_states[GoodbyeState] = GoodbyeState.new(self, @input)
    @game_states[InGameState] = InGameState.new(self, @input)
    @game_states[LogoState] = LogoState.new(self, @input)
    @game_states[OverState] = OverState.new(self, @input)
    @game_states[SetupState] = SetupState.new(self, @input)
  end
end
