# frozen_string_literal: true

require 'rspec'
require './src/board'
require './src/renderers/base_renderer'

class FakeBaseRendererDisplay
  attr_reader :calls,
              :width

  def initialize(width: 39)
    @width = width
    @calls = []
  end

  def draw_text(pos_x, pos_y, text)
    @calls << [pos_x, pos_y, text]
  end
end

describe BaseRenderer do
  subject(:renderer) { described_class.new(display) }

  let(:display) { FakeBaseRendererDisplay.new }

  describe '#draw' do
    it 'does nothing in the base renderer' do
      expect(renderer.draw(instance_double('GameState'))).to be_nil
    end
  end

  describe '#draw_board' do
    it 'draws the board rows and separators' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      board.convert_player1 Cell.new(0, 0)
      board.convert_player2 Cell.new(1, 1)
      board.convert_player1 Cell.new(2, 2)

      renderer.send(:draw_board, board)

      expect(display.calls).to include(
        [14, 6, ' X ┃   ┃   '],
        [14, 7, BaseRenderer::HORIZONTAL_LINE],
        [14, 8, '   ┃ O ┃   '],
        [14, 9, BaseRenderer::HORIZONTAL_LINE],
        [14, 10, '   ┃   ┃ X ']
      )
    end
  end

  describe '#draw_board_line' do
    it 'renders one board line' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      board.convert_player1 Cell.new(0, 0)
      board.convert_player2 Cell.new(1, 0)

      expect(renderer.send(:draw_board_line, board, 0)).to eq(' X ┃ O ┃   ')
    end
  end

  describe '#draw_board_cell' do
    it 'renders known board symbols' do
      board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
      board.convert_player1 Cell.new(0, 0)

      expect(renderer.send(:draw_board_cell, board, 0, 0)).to eq('X')
      expect(renderer.send(:draw_board_cell, board, 1, 1)).to eq(' ')
    end
  end

  describe '#draw_centered' do
    it 'draws text centered around the display width' do
      renderer.send(:draw_centered, 3, 'abc')

      expect(display.calls).to include([18, 3, 'abc'])
    end
  end

  describe '#draw_centered_by_index' do
    it 'draws text using the provided center index' do
      renderer.send(:draw_centered_by_index, 3, 4, 'abc┃def')

      expect(display.calls).to include([15, 3, 'abc┃def'])
    end
  end

  describe '#draw_tips' do
    it 'draws the shared input tips' do
      renderer.send(:draw_tips)

      expect(display.calls).to include(
        [5, 12, BaseRenderer::TIP1],
        [10, 13, BaseRenderer::TIP2],
        [11, 14, BaseRenderer::TIP3]
      )
    end
  end

  describe '#draw_title' do
    it 'draws the title centered on the requested line' do
      renderer.send(:draw_title, 2)

      expect(display.calls).to include([9, 2, BaseRenderer::TITLE])
    end
  end

  describe '#back_tip' do
    it 'returns the setup back tip' do
      expect(renderer.send(:back_tip)).to eq(BaseRenderer::TIP3)
    end
  end
end
