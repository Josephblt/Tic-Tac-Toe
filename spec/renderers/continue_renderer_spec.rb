# frozen_string_literal: true

require 'rspec'
require './src/renderers/base_renderer'
require './src/renderers/continue_renderer'

class FakeContinueRendererDisplay
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

FakeContinueState = Struct.new(:selected_option, keyword_init: true)

describe ContinueRenderer do
  subject(:renderer) { described_class.new(display) }

  let(:display) { FakeContinueRendererDisplay.new }

  describe '#initialize' do
    it 'starts with blink off' do
      expect(renderer.instance_variable_get(:@blink)).to eq(0)
    end
  end

  describe '#draw' do
    it 'draws title, subtitle, options, and tips' do
      renderer.draw(FakeContinueState.new(selected_option: 0))

      expect(display.calls).to include(
        [9, 2, BaseRenderer::TITLE],
        [15, 4, ContinueRenderer::SUBTITLE],
        [13, 7, ContinueRenderer::OPTION1],
        [9, 8, ContinueRenderer::OPTION2],
        [14, 9, ContinueRenderer::OPTION3],
        [5, 12, BaseRenderer::TIP1],
        [10, 13, BaseRenderer::TIP2],
        [11, 14, BaseRenderer::TIP3]
      )
    end

    it 'blinks the first selected option' do
      renderer.instance_variable_set(:@blink, 2)

      renderer.draw(FakeContinueState.new(selected_option: 0))

      expect(display.calls).to include([11, 7, "◀ #{ContinueRenderer::OPTION1} ▶"])
    end

    it 'blinks the second selected option' do
      renderer.instance_variable_set(:@blink, 2)

      renderer.draw(FakeContinueState.new(selected_option: 1))

      expect(display.calls).to include([7, 8, "◀ #{ContinueRenderer::OPTION2} ▶"])
    end

    it 'blinks the third selected option' do
      renderer.instance_variable_set(:@blink, 2)

      renderer.draw(FakeContinueState.new(selected_option: 2))

      expect(display.calls).to include([12, 9, "◀ #{ContinueRenderer::OPTION3} ▶"])
    end

    it 'wraps the blink counter' do
      renderer.instance_variable_set(:@blink, 4)

      renderer.draw(FakeContinueState.new(selected_option: 0))

      expect(renderer.instance_variable_get(:@blink)).to eq(0)
    end
  end
end
