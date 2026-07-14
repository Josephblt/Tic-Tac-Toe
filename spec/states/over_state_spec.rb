# frozen_string_literal: true

require 'rspec'
require './src/states/game_state'
require './src/states/continue_state'
require './src/states/over_state'
require './src/states/setup_state'

FakeOverStateInput = Struct.new(:action_pressed, :cancel_pressed, keyword_init: true) do
  def update
    self
  end
end

class FakeOverStateGame
  attr_reader :changed_state

  def change_to_state(state)
    @changed_state = state
  end
end

describe OverState do
  subject(:state) { described_class.new(game, input) }

  let(:game) { FakeOverStateGame.new }
  let(:input) { FakeOverStateInput.new(action_pressed: false, cancel_pressed: false) }

  describe '#update' do
    it 'changes to continue when action is pressed' do
      input.action_pressed = true

      state.update

      expect(game.changed_state).to eq(ContinueState)
    end

    it 'uses base cancel behavior' do
      input.cancel_pressed = true

      state.update

      expect(game.changed_state).to eq(SetupState)
    end

    it 'does not change state without action or cancel' do
      state.update

      expect(game.changed_state).to be_nil
    end
  end
end
