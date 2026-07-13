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
