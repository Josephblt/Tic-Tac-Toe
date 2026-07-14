# frozen_string_literal: true

require 'rspec'
require './src/displays/game_state_renderer'

describe GameStateRenderer do
  subject(:renderer) { described_class.new(display) }

  let(:display) { instance_double('Display') }

  describe '#initialize' do
    it 'stores the display' do
      expect(renderer.display).to eq(display)
    end
  end

  describe '#draw' do
    it 'does nothing in the base renderer' do
      game_state = instance_double('GameState')

      expect(renderer.draw(game_state)).to be_nil
    end
  end
end
