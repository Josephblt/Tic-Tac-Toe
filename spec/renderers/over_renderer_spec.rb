# frozen_string_literal: true

require 'rspec'
require './src/board'
require './src/renderers/over_renderer'

class FakeOverRendererDisplay
  attr_reader :calls,
              :width

  def initialize
    @width = 39
    @calls = []
  end

  def draw_text(pos_x, pos_y, text)
    @calls << [pos_x, pos_y, text]
  end
end

FakeOverGame = Struct.new(:board, keyword_init: true)
FakeOverState = Struct.new(:game, keyword_init: true)

describe OverRenderer do
  subject(:renderer) { described_class.new(display) }

  let(:display) { FakeOverRendererDisplay.new }

  describe '#initialize' do
    it 'starts with blink off' do
      expect(renderer.instance_variable_get(:@blink)).to eq(0)
    end
  end

  describe '#draw' do
    it 'draws a player one win' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      board.convert_player1 Cell.new(0, 0)
      board.convert_player1 Cell.new(1, 0)
      board.convert_player1 Cell.new(2, 0)

      renderer.draw(FakeOverState.new(game: FakeOverGame.new(board: board)))

      expect(display.calls).to include([11, 4, 'X - PLAYER 1 WINS'])
    end

    it 'draws a player two win' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      board.convert_player2 Cell.new(0, 0)
      board.convert_player2 Cell.new(1, 0)
      board.convert_player2 Cell.new(2, 0)

      renderer.draw(FakeOverState.new(game: FakeOverGame.new(board: board)))

      expect(display.calls).to include([11, 4, 'O - PLAYER 2 WINS'])
    end

    it 'draws a draw result' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)

      renderer.draw(FakeOverState.new(game: FakeOverGame.new(board: board)))

      expect(display.calls).to include([15, 4, OverRenderer::GAME_DRAW])
    end

    it 'draws continue and exit messages while blinking on' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)

      renderer.draw(FakeOverState.new(game: FakeOverGame.new(board: board)))

      expect(display.calls).to include(
        [6, 12, OverRenderer::MESSAGE_CONTINUE],
        [11, 13, OverRenderer::MESSAGE_EXIT]
      )
    end

    it 'hides continue and exit messages while blinking off' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      renderer.instance_variable_set(:@blink, 5)

      renderer.draw(FakeOverState.new(game: FakeOverGame.new(board: board)))

      expect(display.calls).not_to include([6, 12, OverRenderer::MESSAGE_CONTINUE])
      expect(display.calls).not_to include([11, 13, OverRenderer::MESSAGE_EXIT])
    end

    it 'wraps the blink counter' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      renderer.instance_variable_set(:@blink, 10)

      renderer.draw(FakeOverState.new(game: FakeOverGame.new(board: board)))

      expect(renderer.instance_variable_get(:@blink)).to eq(0)
    end
  end
end
