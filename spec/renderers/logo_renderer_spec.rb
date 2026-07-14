# frozen_string_literal: true

require 'rspec'
require './src/renderers/logo_renderer'

class FakeLogoRendererDisplay
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

FakeLogoGame = Struct.new(:exit_allowed, keyword_init: true) do
  def exit_allowed?
    exit_allowed
  end
end

FakeLogoState = Struct.new(:game, keyword_init: true)

describe LogoRenderer do
  subject(:renderer) { described_class.new(display) }

  let(:display) { FakeLogoRendererDisplay.new }

  describe '#initialize' do
    it 'starts with blink off' do
      expect(renderer.instance_variable_get(:@blink)).to eq(0)
    end
  end

  describe '#draw' do
    it 'draws the title and enter message' do
      renderer.draw(FakeLogoState.new(game: FakeLogoGame.new(exit_allowed: false)))

      expect(display.calls).to include(
        [9, 7, BaseRenderer::TITLE],
        [8, 9, LogoRenderer::MESSAGE_ENTER]
      )
    end

    it 'draws the exit message when exit is allowed' do
      renderer.draw(FakeLogoState.new(game: FakeLogoGame.new(exit_allowed: true)))

      expect(display.calls).to include([11, 10, LogoRenderer::MESSAGE_EXIT])
    end

    it 'hides messages while blinking off' do
      renderer.instance_variable_set(:@blink, 5)

      renderer.draw(FakeLogoState.new(game: FakeLogoGame.new(exit_allowed: true)))

      expect(display.calls).not_to include([8, 9, LogoRenderer::MESSAGE_ENTER])
      expect(display.calls).not_to include([11, 10, LogoRenderer::MESSAGE_EXIT])
    end

    it 'wraps the blink counter' do
      renderer.instance_variable_set(:@blink, 10)

      renderer.draw(FakeLogoState.new(game: FakeLogoGame.new(exit_allowed: false)))

      expect(renderer.instance_variable_get(:@blink)).to eq(0)
    end
  end
end
