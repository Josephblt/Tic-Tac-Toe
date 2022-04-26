# frozen_string_literal: true

# Renderer for Game Continue State
class TerminalContinueRenderer < TerminalGameStateRenderer
  SUBTITLE = 'CONTINUE?'
  OPTION1 = 'RESTART MATCH'
  OPTION2 = 'BACK TO MATCH RESULT'
  OPTION3 = 'MATCH SETUP'

  def initialize(display)
    super(display)
    @blink = 0
  end

  def draw(game_state)
    @blink += 1
    @blink = 0 if @blink > 4
    draw_title
    draw_sub_title
    draw_option1 game_state
    draw_option2 game_state
    draw_option3 game_state
    draw_tips
  end

  private

  def draw_option1(game_state)
    text = OPTION1
    text = "◀ #{text} ▶" if game_state.selected_option.zero? && @blink > 2
    draw_centered 7, text
  end

  def draw_option2(game_state)
    text = OPTION2
    text = "◀ #{text} ▶" if game_state.selected_option == 1 && @blink > 2
    draw_centered 8, text
  end

  def draw_option3(game_state)
    text = OPTION3
    text = "◀ #{text} ▶" if game_state.selected_option == 2 && @blink > 2
    draw_centered 9, text
  end

  def draw_sub_title
    draw_centered 4, SUBTITLE
  end

  def draw_title
    draw_centered 2, TITLE
  end
end
