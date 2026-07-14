# frozen_string_literal: true

require 'rspec'
require './src/board'
require './src/renderers/in_game_renderer'

class FakeInGameRendererDisplay
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

FakeInGamePlayer = Struct.new(:active, keyword_init: true) do
  def active?
    active
  end
end
FakeInGameGame = Struct.new(:board, keyword_init: true)
FakeInGameState = Struct.new(
  :game,
  :player1,
  :player2,
  :selected_column,
  :selected_line,
  keyword_init: true
)

describe InGameRenderer do
  subject(:renderer) { described_class.new(display) }

  let(:display) { FakeInGameRendererDisplay.new }
  let(:board) { Board.new(Symbol::CROSS, Symbol::NOUGHT) }

  def state(player1_active: false, player2_active: false, selected_column: 1, selected_line: 1)
    FakeInGameState.new(
      game: FakeInGameGame.new(board: board),
      player1: FakeInGamePlayer.new(active: player1_active),
      player2: FakeInGamePlayer.new(active: player2_active),
      selected_column: selected_column,
      selected_line: selected_line
    )
  end

  describe '#initialize' do
    it 'starts with blink off' do
      expect(renderer.instance_variable_get(:@blink)).to eq(0)
    end
  end

  describe '#draw' do
    it 'draws player one turn in the players header' do
      renderer.draw(state(player1_active: true))

      expect(display.calls.any? do |_, y, text|
        y == 4 && text == '▶ PLAYER 1 - X   O - PLAYER 2  '
      end).to be true
    end

    it 'draws player two turn in the players header' do
      renderer.draw(state(player2_active: true))

      expect(display.calls.any? do |_, y, text|
        y == 4 && text == '  PLAYER 1 - X   O - PLAYER 2 ◀'
      end).to be true
    end

    it 'draws no turn marker when no player is active' do
      renderer.draw(state)

      expect(display.calls.any? do |_, y, text|
        y == 4 && text == 'PLAYER 1 - X   O - PLAYER 2'
      end).to be true
    end

    it 'draws a highlight for a selectable cell while blinking on' do
      renderer.instance_variable_set(:@blink, 2)

      renderer.draw(state(selected_column: 1, selected_line: 1))

      expect(display.calls).to include([19, 8, InGameRenderer::HIGHLIGHT])
    end

    it 'draws an invalid marker for an occupied selected cell while blinking on' do
      board.convert_player1 Cell.new(1, 1)
      renderer.instance_variable_set(:@blink, 2)

      renderer.draw(state(selected_column: 1, selected_line: 1))

      expect(display.calls).to include([19, 8, InGameRenderer::INVALID])
    end

    it 'does not draw the selected cell marker while blinking off' do
      renderer.draw(state(selected_column: 1, selected_line: 1))

      expect(display.calls).not_to include([19, 8, InGameRenderer::HIGHLIGHT])
    end

    it 'wraps the blink counter' do
      renderer.instance_variable_set(:@blink, 4)

      renderer.draw(state)

      expect(renderer.instance_variable_get(:@blink)).to eq(0)
    end
  end
end
