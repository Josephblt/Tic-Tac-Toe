# frozen_string_literal: true

# Renderer for Game Logo State
class TerminalLogoRenderer < TerminalGameStateRenderer
  MESSAGE_ENTER = 'PRESS ENTER TO START...'
  MESSAGE_EXIT = 'OR BACK TO EXIT.'

  def initialize(display)
    super(display)
    @blink = 0
  end

  def draw(_game_state)
    @blink += 1
    @blink = 0 if @blink > 10
    draw_title 7
    draw_message_enter
    draw_message_exit
  end

  private

  def draw_message_enter
    return if @blink > 5

    draw_centered 9, MESSAGE_ENTER
  end

  def draw_message_exit
    return if @blink > 5

    draw_centered 10, MESSAGE_EXIT
  end
end
