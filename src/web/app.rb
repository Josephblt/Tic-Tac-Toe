# frozen_string_literal: true

module Kernel
  def require_relative(_path)
    true
  end
end

# src/symbol.rb
# frozen_string_literal: true

# Describes the available symbols
class Symbol
  EMPTY = 0
  CROSS = 1
  NOUGHT = 2
end


# src/options/ai_options.rb
# frozen_string_literal: true

# Defines and control AI Option selection
class AIOptions
  EASY = 0
  HARD = 1
  IMPOSSIBLE = 2

  attr_reader :selected_option

  def initialize(option)
    @selected_option = option
  end

  def next
    @selected_option += 1
    @selected_option %= 3
  end
end


# src/options/controller_options.rb
# frozen_string_literal: true

# Defines and control Versus Option selection
class ControllerOptions
  HUMAN = 0
  ARTIFICIAL_INTELLIGENCE = 1

  attr_reader :selected_option

  def initialize(option)
    @selected_option = option
  end

  def next
    @selected_option += 1
    @selected_option %= 2
  end
end


# src/options/symbols_options.rb
# frozen_string_literal: true

# Defines and control Symbol Option selection
class SymbolOptions
  REGULAR = 0
  INVERTED = 1

  attr_reader :selected_option

  def initialize
    @selected_option = REGULAR
  end

  def next
    @selected_option += 1
    @selected_option %= 2
  end
end


# src/options/setup.rb
# frozen_string_literal: true

require_relative 'ai_options'
require_relative 'controller_options'
require_relative 'symbols_options'

# Class that holds all configurable game options.
class Setup
  attr_reader :ai1_option,
              :ai2_option,
              :controller1_option,
              :controller2_option,
              :symbol_option

  def initialize
    @ai1_option = AIOptions.new AIOptions::EASY
    @ai2_option = AIOptions.new AIOptions::EASY
    @controller1_option = ControllerOptions.new ControllerOptions::HUMAN
    @controller2_option = ControllerOptions.new ControllerOptions::ARTIFICIAL_INTELLIGENCE
    @symbol_option = SymbolOptions.new
  end

  def change_ai1_options
    @ai1_option.next
  end

  def change_ai2_options
    @ai2_option.next
  end

  def change_controller1_options
    @controller1_option.next
  end

  def change_controller2_options
    @controller2_option.next
  end

  def change_symbol_options
    @symbol_option.next
  end
end


# src/board.rb
# frozen_string_literal: true

# Represents a tic-tac-toe board
class Board
  attr_reader :cells, :player1_symbol, :player2_symbol

  def initialize(player1_symbol, player2_symbol)
    @cells = Array.new(3) { Array.new(3) { Symbol::EMPTY } }
    @player1_symbol = player1_symbol
    @player2_symbol = player2_symbol
  end

  def convert_player1(cell)
    @cells[cell.column][cell.line] = @player1_symbol
  end

  def convert_player2(cell)
    @cells[cell.column][cell.line] = @player2_symbol
  end

  def convert_empty(cell)
    @cells[cell.column][cell.line] = Symbol::EMPTY
  end

  def available_cells
    empty_cells = []
    (0..2).each do |x|
      (0..2).each do |y|
        cell = Cell.new(x, y)
        empty_cells.push(cell) if empty? cell
      end
    end
    empty_cells
  end

  def empty?(cell)
    @cells[cell.column][cell.line] == Symbol::EMPTY
  end

  def full?
    (0..2).each do |x|
      (0..2).each do |y|
        return false if empty? Cell.new x, y
      end
    end
    true
  end

  def game_over?
    win_player1? || win_player2? || full?
  end

  def win_player1?
    win_player?(@player1_symbol)
  end

  def win_player2?
    win_player?(@player2_symbol)
  end

  private

  def win_column?(symbol, column)
    @cells[column][0] == symbol && @cells[column][1] == symbol && @cells[column][2] == symbol
  end

  def win_diagonal?(symbol)
    (@cells[0][0] == symbol && @cells[1][1] == symbol && @cells[2][2] == symbol) ||
      (@cells[2][0] == symbol && @cells[1][1] == symbol && @cells[0][2] == symbol)
  end

  def win_line?(symbol, line)
    @cells[0][line] == symbol && @cells[1][line] == symbol && @cells[2][line] == symbol
  end

  def win_player?(symbol)
    (0..2).each do |i|
      return true if win_column? symbol, i
      return true if win_line? symbol, i
      return true if win_diagonal? symbol
    end
    false
  end
end

# Helper class to define a board cell.
class Cell
  attr_reader :column, :line

  def initialize(column, line)
    @column = column
    @line = line
  end
end


# src/inputs/input.rb
# frozen_string_literal: true

# Base class for input detectors.
class Input
  attr_reader :action_pressed,
              :cancel_pressed,
              :down_pressed,
              :left_pressed,
              :right_pressed,
              :up_pressed

  def update; end

  private

  def reset
    @action_pressed = false
    @cancel_pressed = false
    @down_pressed = false
    @left_pressed = false
    @right_pressed = false
    @up_pressed = false
  end
end


# src/controllers/controller.rb
# frozen_string_literal: true

# Base class for in-game control.
class Controller
  attr_reader :action_pressed,
              :down_pressed,
              :left_pressed,
              :right_pressed,
              :up_pressed

  def initialize(in_game_state)
    @in_game_state = in_game_state
    @active = false
    reset
  end

  def active?
    @active
  end

  def activate
    @active = true
  end

  def deactivate
    @active = false
  end

  def update; end

  def reset
    @action_pressed = false
    @down_pressed = false
    @left_pressed = false
    @right_pressed = false
    @up_pressed = false
  end
end


# src/controllers/human_controller.rb
# frozen_string_literal: true

require_relative 'controller'

# Describes a controller to be used by a human
class HumanController < Controller
  def update
    @action_pressed = @in_game_state.input.action_pressed
    @down_pressed = @in_game_state.input.down_pressed
    @left_pressed = @in_game_state.input.left_pressed
    @right_pressed = @in_game_state.input.right_pressed
    @up_pressed = @in_game_state.input.up_pressed
  end
end


# src/controllers/ai_controller.rb
# frozen_string_literal: true

require_relative 'controller'

# Base class class for AI Based controllers.
class AIController < Controller
  DRAW = 0
  MAX = 1000
  MIN = -1000
  LOSS = -10
  WIN = 10

  def activate
    super
    @depth_aux = 0
    @score_cache = {}
    @ai_move = opening_move(@in_game_state.game.board)
    return if @ai_move

    moves = best_moves(@in_game_state.game.board)
    @ai_move = moves[rand(moves.size)]
  end

  def update
    reset
    if positioned?
      @action_pressed = true
    else
      select_move
    end
  end

  private

  def best_moves(board)
    best_moves = []
    best_score = MIN

    board.available_cells.each do |move|
      move_score = score_after_move board, move, true, 0, MIN, MAX
      next unless move_score >= best_score

      best_moves.clear if move_score > best_score
      best_score = move_score
      best_moves.push move
    end

    best_moves
  end

  def max(value_a, value_b)
    value_a > value_b ? value_a : value_b
  end

  def min(value_a, value_b)
    value_a < value_b ? value_a : value_b
  end

  def minmax(board, depth, maximizer, alpha, beta)
    cache_key = minmax_cache_key(board, depth, maximizer, alpha, beta)
    return @score_cache[cache_key] if @score_cache.key? cache_key

    score = score_player(board, depth)
    if board.game_over? || @max_depth <= depth
      @score_cache[cache_key] = score
      return score
    end

    best_score = maximizer ? MIN : MAX
    board.available_cells.each do |move|
      next_best_score = score_after_move board, move, maximizer, depth + 1, alpha, beta
      if maximizer
        best_score = max(best_score, next_best_score)
        alpha = max(alpha, best_score)
      else
        best_score = min(best_score, next_best_score)
        beta = min(beta, best_score)
      end
      break if beta <= alpha
    end
    @score_cache[cache_key] = best_score
  end

  def move_execute(board, cell, active)
    if active
      @in_game_state.player1.active? ? board.convert_player1(cell) : board.convert_player2(cell)
    else
      @in_game_state.player1.active? ? board.convert_player2(cell) : board.convert_player1(cell)
    end
  end

  def minmax_cache_key(board, depth, maximizer, alpha, beta)
    [
      depth,
      maximizer,
      alpha,
      beta,
      board.cells[0][0],
      board.cells[0][1],
      board.cells[0][2],
      board.cells[1][0],
      board.cells[1][1],
      board.cells[1][2],
      board.cells[2][0],
      board.cells[2][1],
      board.cells[2][2]
    ]
  end

  def move_undo(board, cell)
    board.convert_empty cell
  end

  def opening_move(board)
    return unless @max_depth == MAX
    return unless board.available_cells.size >= 8

    center = Cell.new(1, 1)
    return center if board.empty? center

    [
      Cell.new(0, 0),
      Cell.new(2, 0),
      Cell.new(0, 2),
      Cell.new(2, 2)
    ].find { |cell| board.empty? cell }
  end

  def score_after_move(board, cell, active, depth, alpha, beta)
    move_execute board, cell, active
    move_score = minmax board, depth, !active, alpha, beta
    move_undo board, cell
    move_score
  end

  def score_player(board, depth)
    if @in_game_state.player1.active?
      score_player1(board, depth)
    else
      score_player2(board, depth)
    end
  end

  def score_player1(board, depth)
    if board.win_player1?
      WIN - depth
    elsif board.win_player2?
      LOSS + depth
    else
      DRAW
    end
  end

  def score_player2(board, depth)
    if board.win_player2?
      WIN - depth
    elsif board.win_player1?
      LOSS + depth
    else
      DRAW
    end
  end

  def select_move
    @left_pressed = @in_game_state.selected_column > @ai_move.column
    @right_pressed = @in_game_state.selected_column < @ai_move.column
    @down_pressed  = @in_game_state.selected_line < @ai_move.line
    @up_pressed = @in_game_state.selected_line > @ai_move.line
  end

  def positioned?
    @in_game_state.selected_column == @ai_move.column &&
      @in_game_state.selected_line == @ai_move.line
  end
end

# Easy level AI controller. This controller plays using random moves.
class EasyAIController < AIController
  def initialize(in_game_state)
    super
    @max_depth = 0
  end
end

# Hard level AI controller. This controller makes few mistakes.
class HardAIController < AIController
  def initialize(in_game_state)
    super
    @max_depth = 2
  end
end

# Impossible level AI controller. This controller is unbeatable.
class ImpossibleAIController < AIController
  def initialize(in_game_state)
    super
    @max_depth = MAX
  end
end


# src/states/game_state.rb
# frozen_string_literal: true

# Base class for game states, e.g: Logo, Settings, In-game, Game-Over.
class GameState
  attr_reader :game, :input

  def initialize(game, input)
    @game = game
    @input = input
  end

  def enter; end

  def exit; end

  def update
    @input.update
    return false unless input.cancel_pressed

    @game.change_to_state cancel_state
    true
  end

  private

  def cancel_state
    SetupState
  end
end


# src/states/goodbye_state.rb
# frozen_string_literal: true

# Goodbye state. Shows a nice goodbye message.
class GoodbyeState < GameState
  def update
    @game.stop
  end
end


# src/states/continue_state.rb
# frozen_string_literal: true

# Game continue state. Choose to play again or setup a new match.
class ContinueState < GameState
  attr_reader :selected_option

  def enter
    @selected_option = 0
  end

  def update
    return if super

    update_selected_option
    update_action
  end

  private

  def update_action
    return unless @input.action_pressed

    if @selected_option.zero?
      @game.change_to_state InGameState
    elsif @selected_option == 1
      @game.change_to_state OverState
    elsif @selected_option == 2
      @game.change_to_state SetupState
    end
  end

  def update_selected_option
    return unless @input.down_pressed || @input.up_pressed

    @selected_option += @input.down_pressed ? 1 : -1
    @selected_option %= 3
  end
end


# src/states/over_state.rb
# frozen_string_literal: true

# Game over state. Here you can see the game results.
class OverState < GameState
  def update
    return if super

    @game.change_to_state ContinueState if @input.action_pressed
  end
end


# src/states/logo_state.rb
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


# src/states/setup_state.rb
# frozen_string_literal: true

# Setup state. Here it is possible to setup a match.
class SetupState < GameState
  # fzzzxzaaqqqwredcgbvjmmaaaaaaaaaaaaaaaarrrrtin

  attr_reader :selected_option

  def enter
    @selected_option = 0
  end

  def update
    return if super

    update_selected_option
    update_controller1_option
    update_controller2_option
    update_symbol_option
    update_ai1_option
    update_ai2_option
    @game.change_to_state InGameState if input.action_pressed
  end

  private

  def update_ai1_option
    return unless @selected_option == 2
    return unless input.left_pressed

    @game.setup.change_ai1_options
  end

  def update_ai2_option
    return unless @selected_option == 2
    return unless input.right_pressed

    @game.setup.change_ai2_options
  end

  def update_controller1_option
    return unless @selected_option.zero?
    return unless input.left_pressed

    @game.setup.change_controller1_options
  end

  def update_controller2_option
    return unless @selected_option.zero?
    return unless input.right_pressed

    @game.setup.change_controller2_options
  end

  def update_selected_option
    return unless @input.down_pressed || input.up_pressed

    @selected_option += input.down_pressed ? 1 : -1
    ctrl1_option = @game.setup.controller1_option.selected_option
    ctrl2_option = @game.setup.controller2_option.selected_option
    options_size = ctrl1_option == ControllerOptions::HUMAN && ctrl2_option == ControllerOptions::HUMAN ? 2 : 3
    @selected_option %= options_size
  end

  def update_symbol_option
    return unless @selected_option == 1
    return unless input.left_pressed || input.right_pressed

    @game.setup.change_symbol_options
  end

  def cancel_state
    LogoState
  end
end


# src/states/in_game_state.rb
# frozen_string_literal: true

require_relative '../board'
require_relative '../options/ai_options'
require_relative '../options/controller_options'
require_relative '../controllers/ai_controller'
require_relative '../controllers/human_controller'

# In-game state. Here is where you actually get to play the game.
class InGameState < GameState
  attr_reader :debug_message, :player1, :player2, :selected_column, :selected_line

  def enter
    @game.reset
    @selected_column = 0
    @selected_line = 0
    @player1 = create_controller @game.setup.controller1_option.selected_option, @game.setup.ai1_option.selected_option
    @player2 = create_controller @game.setup.controller2_option.selected_option, @game.setup.ai2_option.selected_option
    alternate_controller
  end

  def update
    return if super

    update_controller
    update_selected_column
    update_selected_line
    update_action
  end

  private

  def alternate_controller
    if @player1.active?
      @player1.deactivate
      @player2.activate
      @controller = @player2
    else
      @player1.activate
      @player2.deactivate
      @controller = @player1
    end
  end

  def create_ai_controller(ai_option)
    case ai_option
    when AIOptions::EASY
      EasyAIController.new self
    when AIOptions::HARD
      HardAIController.new self
    else
      ImpossibleAIController.new self
    end
  end

  def create_controller(controller_option, ai_option)
    case controller_option
    when ControllerOptions::HUMAN
      create_human_controller
    when ControllerOptions::ARTIFICIAL_INTELLIGENCE
      create_ai_controller ai_option
    else
      create_ai_controller ai_option
    end
  end

  def create_human_controller
    HumanController.new self
  end

  def update_action
    return unless @controller.action_pressed

    cell = Cell.new @selected_column, @selected_line
    return unless @game.board.empty? cell

    if @player1.active?
      @game.board.convert_player1 cell
    else
      @game.board.convert_player2 cell
    end

    update_turn
  end

  def update_controller
    @controller.update
  end

  def update_selected_column
    return unless @controller.left_pressed || @controller.right_pressed

    @selected_column += @controller.right_pressed ? 1 : -1
    @selected_column %= 3
  end

  def update_selected_line
    return unless @controller.down_pressed || @controller.up_pressed

    @selected_line += @controller.down_pressed ? 1 : -1
    @selected_line %= 3
  end

  def update_turn
    if @game.board.game_over?
      @game.change_to_state OverState
    else
      alternate_controller
    end
  end
end


# src/displays/game_state_renderer.rb
# frozen_string_literal: true

# Base class for state renderers.
class GameStateRenderer
  attr_reader :display

  def initialize(display)
    @display = display
  end

  def draw(game_state); end
end


# src/renderers/base_renderer.rb
# frozen_string_literal: true

require_relative '../displays/game_state_renderer'
require_relative '../options/ai_options'
require_relative '../options/controller_options'
require_relative '../symbol'

# Base class for game state renderers.
class BaseRenderer < GameStateRenderer
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
    Symbol::CROSS => 'X',
    Symbol::NOUGHT => 'O'
  }.freeze
  TIP1 = '◀ ▲ ▼ ▶ KEYS TO CHANGE/SELECT'
  TIP2 = 'ENTER KEY TO ACCEPT'
  TIP3 = 'BACK KEY TO SETUP'
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
    draw_centered 14, back_tip
  end

  def draw_title(pos_y)
    draw_centered pos_y, TITLE
  end

  def back_tip
    TIP3
  end
end


# src/renderers/continue_renderer.rb
# frozen_string_literal: true

# Renderer for Game Continue State
class ContinueRenderer < BaseRenderer
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


# src/renderers/goodbye_renderer.rb
# frozen_string_literal: true

# Renderer for Game Bye State
class GoodbyeRenderer < BaseRenderer
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


# src/renderers/in_game_renderer.rb
# frozen_string_literal: true

# Renderer for Game In-Game State
class InGameRenderer < BaseRenderer
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


# src/renderers/logo_renderer.rb
# frozen_string_literal: true

# Renderer for Game Logo State
class LogoRenderer < BaseRenderer
  MESSAGE_ENTER = 'PRESS ENTER TO START...'
  MESSAGE_EXIT = 'OR BACK TO EXIT.'

  def initialize(display)
    super(display)
    @blink = 0
  end

  def draw(game_state)
    @blink += 1
    @blink = 0 if @blink > 10
    draw_title 7
    draw_message_enter
    draw_message_exit(game_state)
  end

  private

  def draw_message_enter
    return if @blink > 5

    draw_centered 9, MESSAGE_ENTER
  end

  def draw_message_exit(game_state)
    return if @blink > 5
    return unless game_state.game.exit_allowed?

    draw_centered 10, MESSAGE_EXIT
  end
end


# src/renderers/over_renderer.rb
# frozen_string_literal: true

# Renderer for Game Over State
class OverRenderer < BaseRenderer
  GAME_DRAW = 'DRAW GAME'
  MESSAGE_CONTINUE = 'PRESS ENTER TO CONTINUE...'
  MESSAGE_EXIT = 'BACK KEY TO SETUP'
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


# src/renderers/setup_renderer.rb
# frozen_string_literal: true

require_relative '../options/ai_options'
require_relative '../options/symbols_options'
require_relative '../options/controller_options'

# Renderer for Game Setup State
class SetupRenderer < BaseRenderer
  SUBTITLE = 'MATCH SETUP'
  SELECTOR_LEFT = '◀'
  SELECTOR_RIGHT = '▶'
  SYMBOL_OPTIONS = {
    SymbolOptions::REGULAR => "#{SYMBOLS[Symbol::CROSS]} ┃ #{SYMBOLS[Symbol::NOUGHT]}",
    SymbolOptions::INVERTED => "#{SYMBOLS[Symbol::NOUGHT]} ┃ #{SYMBOLS[Symbol::CROSS]}"
  }.freeze

  def initialize(display)
    super(display)
    @blink = 0
  end

  def draw(game_state)
    @blink += 1
    @blink = 0 if @blink > 4
    draw_title 2
    draw_sub_title
    draw_players_header
    draw_controller_option game_state
    draw_symbol_option game_state
    draw_ai_option game_state
    draw_tips
  end

  private

  def ai1_option(game_state)
    controller_option = game_state.game.setup.controller1_option.selected_option
    if controller_option == ControllerOptions::ARTIFICIAL_INTELLIGENCE
      ai_option = AI_OPTIONS[game_state.game.setup.ai1_option.selected_option]
      ai_option = draw_left_selector(ai_option) if game_state.selected_option == 2 && @blink > 2
    else
      ai_option = ''
    end
    ai_option
  end

  def ai2_option(game_state)
    controller_option = game_state.game.setup.controller2_option.selected_option
    if controller_option == ControllerOptions::ARTIFICIAL_INTELLIGENCE
      ai_option = AI_OPTIONS[game_state.game.setup.ai2_option.selected_option]
      ai_option = draw_right_selector(ai_option) if game_state.selected_option == 2 && @blink > 2
    else
      ai_option = ''
    end
    ai_option
  end

  def controller1_option(game_state)
    controller_option = CONTROLLER_OPTIONS[game_state.game.setup.controller1_option.selected_option]
    controller_option = draw_left_selector(controller_option) if game_state.selected_option.zero? && @blink > 2
    controller_option
  end

  def controller2_option(game_state)
    controller_option = CONTROLLER_OPTIONS[game_state.game.setup.controller2_option.selected_option]
    controller_option = draw_right_selector(controller_option) if game_state.selected_option.zero? && @blink > 2
    controller_option
  end

  def draw_ai_option(game_state)
    ai_option = "#{ai1_option game_state} ┃ #{ai2_option game_state}"
    center_index = ai_option.index '┃'
    draw_centered_by_index 10, center_index, ai_option
  end

  def draw_controller_option(game_state)
    controller_option = "#{controller1_option game_state} ┃ #{controller2_option game_state}"
    center_index = controller_option.index '┃'
    draw_centered_by_index 8, center_index, controller_option
  end

  def draw_players_header
    line1 = PLAYERS_HEADER.dup
    line1['-'] = '┃'
    line2 = '━━━━━━━━━━━━━╋━━━━━━━━━━━━━'
    draw_centered 6, line1
    draw_centered 7, line2
  end

  def draw_selectors(option)
    "#{SELECTOR_LEFT} #{option} #{SELECTOR_RIGHT}"
  end

  def draw_left_selector(option)
    "#{SELECTOR_LEFT} #{option}"
  end

  def draw_right_selector(option)
    "#{option} #{SELECTOR_RIGHT}"
  end

  def draw_sub_title
    draw_centered 4, SUBTITLE
  end

  def draw_symbol_option(game_state)
    symbol_options = SYMBOL_OPTIONS[game_state.game.setup.symbol_option.selected_option]
    symbol_options = draw_selectors(symbol_options) if game_state.selected_option == 1 && @blink > 2
    center_index = symbol_options.index '┃'
    draw_centered_by_index 9, center_index, symbol_options
  end

  def back_tip
    'BACK KEY TO LOGO'
  end
end


# src/displays/display.rb
# frozen_string_literal: true

require_relative '../states/game_state'
require_relative '../states/goodbye_state'
require_relative '../states/continue_state'
require_relative '../states/over_state'
require_relative '../states/logo_state'
require_relative '../states/setup_state'
require_relative '../states/in_game_state'
require_relative '../renderers/base_renderer'
require_relative '../renderers/continue_renderer'
require_relative '../renderers/goodbye_renderer'
require_relative '../renderers/in_game_renderer'
require_relative '../renderers/logo_renderer'
require_relative '../renderers/setup_renderer'
require_relative '../renderers/over_renderer'

# Base class for screen renderers.
class Display
  attr_reader :width,
              :height,
              :renderers

  def initialize(width, height)
    @width = width
    @height = height
    initialize_renderers
    reset_display
  end

  def draw_text(pos_x, pos_y, text)
    text.each_char.with_index do |char, index|
      x = pos_x + index
      next if x.negative? || x >= @width
      next if pos_y.negative? || pos_y >= @height

      @display_matrix[x][pos_y] = char
    end
  end

  def refresh
    draw_borders
    write_frame
    after_refresh
    reset_display
  end

  private

  def initialize_renderers
    @renderers = {
      ContinueState => ContinueRenderer.new(self),
      GoodbyeState => GoodbyeRenderer.new(self),
      InGameState => InGameRenderer.new(self),
      LogoState => LogoRenderer.new(self),
      OverState => OverRenderer.new(self),
      SetupState => SetupRenderer.new(self)
    }
  end

  def draw_borders
    draw_corner_borders
    draw_horizontal_borders
    draw_vertical_borders
  end

  def draw_corner_borders
    @display_matrix[0][0] = '╔'
    @display_matrix[@width - 1][0] = '╗'
    @display_matrix[0][@height - 1] = '╚'
    @display_matrix[@width - 1][@height - 1] = '╝'
  end

  def draw_horizontal_borders
    (1..@width - 2).each do |x|
      @display_matrix[x][0] = '═'
      @display_matrix[x][@height - 1] = '═'
    end
  end

  def draw_vertical_borders
    (1..@height - 2).each do |y|
      @display_matrix[0][y] = '║'
      @display_matrix[@width - 1][y] = '║'
    end
  end

  def after_refresh; end

  def frame_text
    (0..@height - 1).map do |y|
      (0..@width - 1).map { |x| @display_matrix[x][y] }.join
    end.join("\r\n")
  end

  def reset_display
    @display_matrix = Array.new(@width) { Array.new(@height) { ' ' } }
  end

  def write_frame; end
end


# src/game.rb
# frozen_string_literal: true

require_relative 'options/setup'
require_relative 'states/game_state'
require_relative 'states/goodbye_state'
require_relative 'states/continue_state'
require_relative 'states/over_state'
require_relative 'states/logo_state'
require_relative 'states/setup_state'
require_relative 'states/in_game_state'

# Simple implementation of the famous Tic-Tac-Toe game.
class Game
  LOOP_MODE_CONTINUOUS = :continuous
  LOOP_MODE_EXITABLE = :exitable

  attr_reader :board,
              :loop_mode,
              :running,
              :setup

  def initialize(display, input, loop_mode: LOOP_MODE_EXITABLE)
    @display = display
    @input = input
    @loop_mode = loop_mode
    @running = false
    @setup = Setup.new
    initialize_game_states
  end

  def exit_allowed?
    @loop_mode == LOOP_MODE_EXITABLE
  end

  def change_to_state(state)
    @current_game_state&.exit
    @current_game_state = @game_states[state]
    @current_game_state&.enter
  end

  def start
    change_to_state LogoState
    @running = true
  end

  def update
    return false unless @running

    @current_game_state.update
    @display.renderers[@current_game_state.class].draw(@current_game_state)
    @display.refresh
    @running
  end

  def running?
    @running
  end

  def stop
    @running = false
  end

  def finalize
    @display.finalize
  end

  def reset
    @board = if @setup.symbol_option.selected_option == SymbolOptions::REGULAR
               Board.new(Symbol::CROSS, Symbol::NOUGHT)
             else
               Board.new(Symbol::NOUGHT, Symbol::CROSS)
             end
  end

  private

  def initialize_game_states
    @game_states = {}
    @game_states[ContinueState] = ContinueState.new(self, @input)
    @game_states[GoodbyeState] = GoodbyeState.new(self, @input)
    @game_states[InGameState] = InGameState.new(self, @input)
    @game_states[LogoState] = LogoState.new(self, @input)
    @game_states[OverState] = OverState.new(self, @input)
    @game_states[SetupState] = SetupState.new(self, @input)
  end
end


# src/inputs/web_input.rb
# frozen_string_literal: true

require 'js'
require_relative 'input'

# Web input adapter. The JavaScript side normalizes keyboard and button
# events into the same queue values before Ruby reads them.
class WebInput < Input
  def initialize(bridge)
    super()
    @bridge = bridge
    reset
  end

  def update
    reset

    loop do
      key = @bridge.call(:readKey).to_s
      break if key.empty?

      on_key_press(key)
    end
  end

  private

  def on_key_press(key)
    case key
    when 'left'
      @left_pressed = true
    when 'down'
      @down_pressed = true
    when 'right'
      @right_pressed = true
    when 'up'
      @up_pressed = true
    when "\r", "\n"
      @action_pressed = true
    when "\u007F", "\b"
      @cancel_pressed = true
    end
  end
end


# src/displays/web_terminal_display.rb
# frozen_string_literal: true

require 'js'
require_relative 'display'

# Web display adapter. It reuses the shared text state renderers but
# writes complete frames into xterm.js instead of using tty-cursor.
class WebTerminalDisplay < Display
  def initialize(bridge)
    @bridge = bridge
    super(39, 17)
    @bridge.call(:write, "\e[?25l\e[2J")
  end

  def finalize
    @bridge.call(:write, "\e[?25h\r\n")
  end

  private

  def write_frame
    @bridge.call(:write, "\e[H#{frame_text}")
  end
end


# src/entrypoints/web_entrypoint.rb
# frozen_string_literal: true

require 'js'
require_relative '../game'
require_relative '../inputs/web_input'
require_relative '../displays/web_terminal_display'

class WebEntrypoint
  TICK_MS = 120

  def self.start(input_class)
    bridge = JS.global[:terminalBridge]
    display = WebTerminalDisplay.new(bridge)
    input = input_class.new(bridge)
    game = Game.new(display, input, loop_mode: Game::LOOP_MODE_CONTINUOUS)
    game.start

    interval = nil
    tick = proc do
      running = game.update
      unless running
        game.finalize
        JS.global.clearInterval(interval)
      end
    end

    interval = JS.global.setInterval(tick, TICK_MS)
  end
end
