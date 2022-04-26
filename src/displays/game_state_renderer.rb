# frozen_string_literal: true

# Base class for state renderers.
class GameStateRenderer
  attr_reader :display

  def initialize(display)
    @display = display
  end

  def draw(game_state); end
end
