# frozen_string_literal: true

# Game over state. Here you can see the game results.
class OverState < GameState
  def update
    super
    @game.change_to_state ContinueState if @input.action_pressed
  end
end
