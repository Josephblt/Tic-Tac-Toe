# frozen_string_literal: true

# Game over state. Here you can see the game results.
class OverState < GameState
  def update
    return if super

    @game.change_to_state ContinueState if @input.action_pressed
  end
end
