# frozen_string_literal: true

require 'rspec'
require './src/displays/display'

class FakeDisplay < Display
  attr_reader :after_refresh_called,
              :written_frame

  private

  def after_refresh
    @after_refresh_called = true
  end

  def write_frame
    @written_frame = frame_text
  end
end

describe Display do
  subject(:display) { FakeDisplay.new(5, 4) }

  describe '#initialize' do
    it 'stores dimensions' do
      expect(display.width).to eq(5)
      expect(display.height).to eq(4)
    end

    it 'initializes state renderers' do
      expect(display.renderers.keys).to contain_exactly(
        ContinueState,
        GoodbyeState,
        InGameState,
        LogoState,
        OverState,
        SetupState
      )
    end

    it 'starts with a blank display matrix' do
      matrix = display.instance_variable_get(:@display_matrix)

      expect(matrix).to eq(
        [
          [' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ']
        ]
      )
    end
  end

  describe '#draw_text' do
    it 'writes text into the display matrix' do
      display.draw_text(1, 2, 'abc')

      matrix = display.instance_variable_get(:@display_matrix)
      expect(matrix[1][2]).to eq('a')
      expect(matrix[2][2]).to eq('b')
      expect(matrix[3][2]).to eq('c')
    end

    it 'clips text outside the horizontal display bounds' do
      display.draw_text(-1, 1, 'abcd')

      matrix = display.instance_variable_get(:@display_matrix)
      expect(matrix[0][1]).to eq('b')
      expect(matrix[1][1]).to eq('c')
      expect(matrix[2][1]).to eq('d')
      expect(matrix[3][1]).to eq(' ')
    end

    it 'ignores text outside the vertical display bounds' do
      display.draw_text(1, -1, 'abc')
      display.draw_text(1, 4, 'xyz')

      matrix = display.instance_variable_get(:@display_matrix)
      expect(matrix.flatten).to all(eq(' '))
    end
  end

  describe '#refresh' do
    it 'draws borders into the written frame' do
      display.refresh

      expect(display.written_frame).to eq(
        "╔═══╗\r\n" \
        "║   ║\r\n" \
        "║   ║\r\n" \
        '╚═══╝'
      )
    end

    it 'writes text inside the bordered frame' do
      display.draw_text(2, 1, 'x')
      display.refresh

      expect(display.written_frame).to eq(
        "╔═══╗\r\n" \
        "║ x ║\r\n" \
        "║   ║\r\n" \
        '╚═══╝'
      )
    end

    it 'runs the post-refresh hook' do
      display.refresh

      expect(display.after_refresh_called).to be true
    end

    it 'resets the display matrix after writing' do
      display.draw_text(2, 1, 'x')
      display.refresh

      matrix = display.instance_variable_get(:@display_matrix)
      expect(matrix.flatten).to all(eq(' '))
    end
  end
end
