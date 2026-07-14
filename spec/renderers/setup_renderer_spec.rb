# frozen_string_literal: true

require 'rspec'
require './src/options/setup'
require './src/renderers/setup_renderer'

class FakeSetupRendererDisplay
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

FakeSetupGame = Struct.new(:setup, keyword_init: true)
FakeSetupState = Struct.new(:game, :selected_option, keyword_init: true)

describe SetupRenderer do
  subject(:renderer) { described_class.new(display) }

  let(:display) { FakeSetupRendererDisplay.new }
  let(:setup) { Setup.new }

  def state(selected_option)
    FakeSetupState.new(
      game: FakeSetupGame.new(setup: setup),
      selected_option: selected_option
    )
  end

  def drawn_texts
    display.calls.map(&:last)
  end

  describe '#initialize' do
    it 'starts with blink off' do
      expect(renderer.instance_variable_get(:@blink)).to eq(0)
    end
  end

  describe '#draw' do
    it 'draws default setup options and tips' do
      renderer.draw(state(0))

      expect(drawn_texts).to include(
        BaseRenderer::TITLE,
        SetupRenderer::SUBTITLE,
        'PLAYER 1 ┃ PLAYER 2',
        '━━━━━━━━━━━━━╋━━━━━━━━━━━━━',
        'HUMAN ┃ AI',
        'X ┃ O',
        ' ┃ EASY',
        BaseRenderer::TIP1,
        BaseRenderer::TIP2,
        'BACK KEY TO LOGO'
      )
    end

    it 'draws controller selectors while controller option is selected' do
      renderer.instance_variable_set(:@blink, 2)

      renderer.draw(state(0))

      expect(drawn_texts).to include('◀ HUMAN ┃ AI ▶')
    end

    it 'draws symbol selectors while symbol option is selected' do
      renderer.instance_variable_set(:@blink, 2)

      renderer.draw(state(1))

      expect(drawn_texts).to include('◀ X ┃ O ▶')
    end

    it 'draws AI selectors for artificial intelligence controllers' do
      setup.change_controller1_options
      renderer.instance_variable_set(:@blink, 2)

      renderer.draw(state(2))

      expect(drawn_texts).to include('◀ EASY ┃ EASY ▶')
    end

    it 'hides AI options for human controllers' do
      setup.change_controller2_options

      renderer.draw(state(2))

      expect(drawn_texts).to include(' ┃ ')
    end

    it 'draws inverted symbol options' do
      setup.change_symbol_options

      renderer.draw(state(1))

      expect(drawn_texts).to include('O ┃ X')
    end

    it 'wraps the blink counter' do
      renderer.instance_variable_set(:@blink, 4)

      renderer.draw(state(0))

      expect(renderer.instance_variable_get(:@blink)).to eq(0)
    end
  end
end
