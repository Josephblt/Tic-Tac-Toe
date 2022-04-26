# frozen_string_literal: true

# Logo state. Shows the name of the game and some tips.
class LogoState < GameState
  def update
    super
    @game.change_to_state SetupState if input.action_pressed
  end
end
