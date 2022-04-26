# frozen_string_literal: true

# Renderer for Game Bye State
class TerminalGoodbyeRenderer < TerminalGameStateRenderer
  GOODBYE_MESSAGE = 'THANKS FOR PLAYING.'

  def draw(_game_state)
    draw_title 7
    draw_goodbye_message
  end

  private

  def draw_goodbye_message
    draw_centered 9, GOODBYE_MESSAGE
  end
end
