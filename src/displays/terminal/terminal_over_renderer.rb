# frozen_string_literal: true

# Renderer for Game Over State
class TerminalOverRenderer < TerminalGameStateRenderer
  GAME_DRAW = 'DRAW GAME'
  MESSAGE_CONTINUE = 'PRESS ENTER TO CONTINUE...'
  MESSAGE_EXIT = 'OR BACK TO EXIT.'
  PLAYER1_WINS = "#{PLAYER1} WINS"
  PLAYER2_WINS = "#{PLAYER2} WINS"

  def initialize(display)
    super(display)
    @blink = 0
  end

  def draw(game_state)
    @blink += 1
    @blink = 0 if @blink > 10
    draw_title
    draw_game_result game_state.game.board
    draw_board game_state.game.board
    draw_message_continue
    draw_message_exit
  end

  private

  def draw_game_result(board)
    game_result = if board.win_player1?
                    "#{SYMBOLS[board.player1_symbol]} - #{PLAYER1_WINS}"
                  elsif board.win_player2?
                    "#{SYMBOLS[board.player2_symbol]} - #{PLAYER2_WINS}"
                  else
                    GAME_DRAW
                  end
    draw_centered 4, game_result
  end

  def draw_message_continue
    return if @blink > 5

    draw_centered 12, MESSAGE_CONTINUE
  end

  def draw_message_exit
    return if @blink > 5

    draw_centered 13, MESSAGE_EXIT
  end

  def draw_title
    draw_centered 2, TITLE
  end
end
