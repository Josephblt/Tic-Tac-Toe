# frozen_string_literal: true

require 'rspec'
require './src/renderers/goodbye_renderer'

class FakeGoodbyeRendererDisplay
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

describe GoodbyeRenderer do
  subject(:renderer) { described_class.new(display) }

  let(:display) { FakeGoodbyeRendererDisplay.new }

  describe '#draw' do
    it 'draws the title and goodbye message' do
      renderer.draw(instance_double('GoodbyeState'))

      expect(display.calls).to include(
        [9, 7, BaseRenderer::TITLE],
        [10, 9, GoodbyeRenderer::GOODBYE_MESSAGE]
      )
    end
  end
end
