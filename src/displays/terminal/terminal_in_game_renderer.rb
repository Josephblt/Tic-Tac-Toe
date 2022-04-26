# frozen_string_literal: true

# Renderer for Game Logo State
class TerminalInGameRenderer < TerminalGameStateRenderer
  HIGHLIGHT = '*'
  INVALID = ' '
  PLAYER_1_TURN = '▶'
  PLAYER_2_TURN = '◀'

  def initialize(display)
    super(display)
    @blink = 0
  end

  def draw(game_state)
    @blink += 1
    @blink = 0 if @blink > 4
    draw_title 2
    draw_players_header game_state
    draw_board game_state.game.board
    draw_selected_column_line game_state
    draw_tips
  end

  private

  def selectable?(game_state)
    cell = Cell.new game_state.selected_column, game_state.selected_line
    game_state.game.board.empty? cell
  end

  def draw_players_header(game_state)
    player1_text = "#{PLAYER1} - #{SYMBOLS[game_state.game.board.player1_symbol]}"
    player2_text = "#{SYMBOLS[game_state.game.board.player2_symbol]} - #{PLAYER2}"
    player_header = "#{player1_text}   #{player2_text}"
    player_header = draw_player_turn(game_state, player_header)
    draw_centered 4, player_header
  end

  def draw_player_turn(game_state, player_header)
    if @blink < 2
      player_header = if game_state.player1.active?
                        "#{PLAYER_1_TURN} #{player_header}  "
                      elsif game_state.player2.active?
                        "  #{player_header} #{PLAYER_2_TURN}"
                      else
                        player_header
                      end
    end
    player_header
  end

  def draw_selected_column_line(game_state)
    column = (display.width / 2) - (HORIZONTAL_LINE.size / 2) + ((game_state.selected_column * 4) + 1)
    line = BOARD_LINE + (game_state.selected_line * 2)
    text = if selectable? game_state
             HIGHLIGHT
           else
             INVALID
           end

    display.draw_text column, line, text if @blink > 2
  end
end
