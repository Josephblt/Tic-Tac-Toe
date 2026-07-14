# frozen_string_literal: true

# Logo state. Shows the name of the game and some tips.
class LogoState < GameState
  def update
    return if super

    @game.change_to_state SetupState if input.action_pressed
  end

  private

  def cancel_state
    game.exit_allowed? ? GoodbyeState : LogoState
  end
end
