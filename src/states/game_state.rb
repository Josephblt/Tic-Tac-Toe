# frozen_string_literal: true

# Base class for game states, e.g: Logo, Settings, In-game, Game-Over.
class GameState
  attr_reader :game, :input

  def initialize(game, input)
    @game = game
    @input = input
  end

  def enter; end

  def exit; end

  def update
    @input.update
    return false unless input.cancel_pressed

    @game.change_to_state cancel_state
    true
  end

  private

  def cancel_state
    SetupState
  end
end
