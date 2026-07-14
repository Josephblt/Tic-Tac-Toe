# frozen_string_literal: true

require 'rspec'
require './src/board'
require './src/controllers/ai_controller'
require './src/symbol'

class FakeAIPlayer
  def initialize(active)
    @active = active
  end

  def active?
    @active
  end
end

class FakeAIGame
  attr_reader :board

  def initialize(board)
    @board = board
  end
end

class FakeAIInGameState
  attr_reader :game,
              :player1,
              :selected_column,
              :selected_line

  def initialize(board, player1_active: false, selected_column: 0, selected_line: 0)
    @game = FakeAIGame.new(board)
    @player1 = FakeAIPlayer.new(player1_active)
    @selected_column = selected_column
    @selected_line = selected_line
  end
end

describe ImpossibleAIController do
  describe '#initialize' do
    it 'uses the maximum search depth' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      controller = described_class.new FakeAIInGameState.new(board)

      expect(controller.instance_variable_get(:@max_depth)).to eq(AIController::MAX)
    end
  end

  describe 'activate' do
    it 'selects the center as an opening move when it is available' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      board.convert_player1 Cell.new(0, 0)

      controller = ImpossibleAIController.new FakeAIInGameState.new(board)
      controller.activate

      move = controller.instance_variable_get(:@ai_move)
      expect(move.column).to eq(1)
      expect(move.line).to eq(1)
    end

    it 'selects a corner as an opening move when the center is taken' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      board.convert_player1 Cell.new(1, 1)

      controller = ImpossibleAIController.new FakeAIInGameState.new(board)
      controller.activate

      move = controller.instance_variable_get(:@ai_move)
      expect([[0, 0], [2, 0], [0, 2], [2, 2]]).to include([move.column, move.line])
    end

    it 'selects an immediate winning move' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      board.convert_player2 Cell.new(0, 0)
      board.convert_player2 Cell.new(1, 0)
      board.convert_player1 Cell.new(0, 1)

      controller = ImpossibleAIController.new FakeAIInGameState.new(board)
      controller.activate

      move = controller.instance_variable_get(:@ai_move)
      expect(move.column).to eq(2)
      expect(move.line).to eq(0)
    end

    it 'populates the score cache' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      board.convert_player1 Cell.new(0, 0)
      board.convert_player2 Cell.new(1, 1)

      controller = ImpossibleAIController.new FakeAIInGameState.new(board)
      controller.activate

      score_cache = controller.instance_variable_get(:@score_cache)
      expect(score_cache.size).to be > 0
    end
  end

  describe '#update' do
    it 'presses action when the selected cell is the AI move' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      controller = described_class.new FakeAIInGameState.new(
        board,
        selected_column: 1,
        selected_line: 1
      )
      controller.instance_variable_set(:@ai_move, Cell.new(1, 1))

      controller.update

      expect(controller.action_pressed).to be true
      expect(controller.left_pressed).to be false
      expect(controller.right_pressed).to be false
      expect(controller.down_pressed).to be false
      expect(controller.up_pressed).to be false
    end

    it 'presses directions toward the AI move' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      controller = described_class.new FakeAIInGameState.new(
        board,
        selected_column: 1,
        selected_line: 1
      )
      controller.instance_variable_set(:@ai_move, Cell.new(0, 2))

      controller.update

      expect(controller.action_pressed).to be false
      expect(controller.left_pressed).to be true
      expect(controller.right_pressed).to be false
      expect(controller.down_pressed).to be true
      expect(controller.up_pressed).to be false
    end

    it 'clears stale movement before selecting the next movement' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      controller = described_class.new FakeAIInGameState.new(
        board,
        selected_column: 1,
        selected_line: 1
      )
      controller.instance_variable_set(:@left_pressed, true)
      controller.instance_variable_set(:@down_pressed, true)
      controller.instance_variable_set(:@ai_move, Cell.new(2, 0))

      controller.update

      expect(controller.left_pressed).to be false
      expect(controller.right_pressed).to be true
      expect(controller.down_pressed).to be false
      expect(controller.up_pressed).to be true
    end
  end

  describe '#score_player' do
    it 'scores a player one win from player one perspective' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      board.convert_player1 Cell.new(0, 0)
      board.convert_player1 Cell.new(1, 0)
      board.convert_player1 Cell.new(2, 0)
      controller = described_class.new FakeAIInGameState.new(board, player1_active: true)

      expect(controller.send(:score_player, board, 2)).to eq(AIController::WIN - 2)
    end

    it 'scores a player two win as a player one loss from player one perspective' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      board.convert_player2 Cell.new(0, 0)
      board.convert_player2 Cell.new(1, 0)
      board.convert_player2 Cell.new(2, 0)
      controller = described_class.new FakeAIInGameState.new(board, player1_active: true)

      expect(controller.send(:score_player, board, 3)).to eq(AIController::LOSS + 3)
    end

    it 'scores an unfinished board as a draw from player one perspective' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      controller = described_class.new FakeAIInGameState.new(board, player1_active: true)

      expect(controller.send(:score_player, board, 0)).to eq(AIController::DRAW)
    end
  end
end

describe EasyAIController do
  describe '#initialize' do
    it 'uses zero search depth' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      controller = described_class.new FakeAIInGameState.new(board)

      expect(controller.instance_variable_get(:@max_depth)).to eq(0)
    end
  end
end

describe HardAIController do
  describe '#initialize' do
    it 'uses limited search depth' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      controller = described_class.new FakeAIInGameState.new(board)

      expect(controller.instance_variable_get(:@max_depth)).to eq(2)
    end
  end
end
