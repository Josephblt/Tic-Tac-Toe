# frozen_string_literal: true

require 'rspec'
require './src/states/game_state'
require './src/states/goodbye_state'

class FakeGoodbyeStateGame
  attr_reader :stopped

  def stop
    @stopped = true
  end
end

describe GoodbyeState do
  subject(:state) { described_class.new(game, instance_double('Input')) }

  let(:game) { FakeGoodbyeStateGame.new }

  describe '#update' do
    it 'stops the game' do
      state.update

      expect(game.stopped).to be true
    end
  end
end
