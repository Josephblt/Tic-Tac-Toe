# frozen_string_literal: true

require 'rspec'
require './src/states/game_state'
require './src/states/setup_state'

FakeStateInput = Struct.new(
  :action_pressed,
  :cancel_pressed,
  :down_pressed,
  :left_pressed,
  :right_pressed,
  :up_pressed,
  keyword_init: true
) do
  def update
    self
  end
end

class FakeStateGame
  attr_reader :changed_state

  def change_to_state(state)
    @changed_state = state
  end
end

describe GameState do
  subject(:state) { described_class.new(game, input) }

  let(:game) { FakeStateGame.new }
  let(:input) { FakeStateInput.new(cancel_pressed: false) }

  describe '#initialize' do
    it 'stores game and input' do
      expect(state.game).to eq(game)
      expect(state.input).to eq(input)
    end
  end

  describe '#enter' do
    it 'does nothing in the base state' do
      expect(state.enter).to be_nil
    end
  end

  describe '#exit' do
    it 'does nothing in the base state' do
      expect(state.exit).to be_nil
    end
  end

  describe '#update' do
    it 'updates input and returns false when cancel is not pressed' do
      expect(state.update).to be false
      expect(game.changed_state).to be_nil
    end

    it 'changes to the cancel state and returns true when cancel is pressed' do
      input.cancel_pressed = true

      expect(state.update).to be true
      expect(game.changed_state).to eq(SetupState)
    end
  end
end
