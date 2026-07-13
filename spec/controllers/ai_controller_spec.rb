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

  def initialize(board, player1_active: false)
    @game = FakeAIGame.new(board)
    @player1 = FakeAIPlayer.new(player1_active)
    @selected_column = 0
    @selected_line = 0
  end
end

describe ImpossibleAIController do
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

      controller = ImpossibleAIController.new FakeAIInGameState.new(board)
      controller.activate

      score_cache = controller.instance_variable_get(:@score_cache)
      expect(score_cache.size).to be > 0
    end
  end
end
