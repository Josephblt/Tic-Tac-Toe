# frozen_string_literal: true

require_relative '../game_state_renderer'
require_relative '../../symbol'

# Base class for all terminal game state renderers.
class TerminalGameStateRenderer < GameStateRenderer
  AI_OPTIONS = {
    AIOptions::EASY => 'EASY',
    AIOptions::HARD => 'HARD',
    AIOptions::IMPOSSIBLE => 'IMPOSSIBLE'
  }.freeze
  BOARD_LINE = 6
  CONTROLLER_OPTIONS = {
    ControllerOptions::ARTIFICIAL_INTELLIGENCE => 'AI',
    ControllerOptions::HUMAN => 'HUMAN'
  }.freeze
  HORIZONTAL_LINE = '━━━╋━━━╋━━━'
  PLAYER1 = 'PLAYER 1'
  PLAYER2 = 'PLAYER 2'
  PLAYERS_HEADER = "#{PLAYER1} - #{PLAYER2}"
  SYMBOLS = {
    Symbol::EMPTY => ' ',
    Symbol::CROSS => '🗙',
    Symbol::NOUGHT => '🞉'
  }.freeze
  TIP1 = 'ARROW KEYS TO CHANGE/SELECT'
  TIP2 = 'ENTER KEY TO ACCEPT'
  TIP3 = 'ESC KEY TO QUIT'
  TITLE = 'SCHOLL\'S TIC-TAC-TOE!'

  def draw(game_state) end

  private

  def draw_board(board)
    draw_centered 6, draw_board_line(board, 0)
    draw_centered 7, HORIZONTAL_LINE
    draw_centered 8, draw_board_line(board, 1)
    draw_centered 9, HORIZONTAL_LINE
    draw_centered 10, draw_board_line(board, 2)
  end

  def draw_board_line(board, line)
    " #{draw_board_cell board, 0, line} ┃ " \
    "#{draw_board_cell board, 1, line} ┃ " \
    "#{draw_board_cell board, 2, line} "
  end

  def draw_board_cell(board, column, line)
    (SYMBOLS[board.cells[column][line]]).to_s
  end

  def draw_centered(pos_y, text)
    pos_x = (@display.width / 2) - (text.size / 2)
    display.draw_text pos_x, pos_y, text
  end

  def draw_centered_by_index(pos_y, center_index, text)
    pos_x = (@display.width / 2) - center_index
    display.draw_text pos_x, pos_y, text
  end

  def draw_tips
    draw_centered 12, TIP1
    draw_centered 13, TIP2
    draw_centered 14, TIP3
  end

  def draw_title(pos_y)
    draw_centered pos_y, TITLE
  end
end
