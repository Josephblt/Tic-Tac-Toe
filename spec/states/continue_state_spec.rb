# frozen_string_literal: true

require 'rspec'
require './src/states/game_state'
require './src/states/continue_state'
require './src/states/in_game_state'
require './src/states/over_state'
require './src/states/setup_state'

FakeContinueStateInput = Struct.new(
  :action_pressed,
  :cancel_pressed,
  :down_pressed,
  :up_pressed,
  keyword_init: true
) do
  def update
    self
  end
end

class FakeContinueStateGame
  attr_reader :changed_state

  def change_to_state(state)
    @changed_state = state
  end
end

describe ContinueState do
  subject(:state) { described_class.new(game, input) }

  let(:game) { FakeContinueStateGame.new }
  let(:input) do
    FakeContinueStateInput.new(
      action_pressed: false,
      cancel_pressed: false,
      down_pressed: false,
      up_pressed: false
    )
  end

  describe '#enter' do
    it 'selects the first option' do
      state.enter

      expect(state.selected_option).to eq(0)
    end
  end

  describe '#update' do
    before do
      state.enter
    end

    it 'moves selected option down with wraparound' do
      input.down_pressed = true

      3.times { state.update }

      expect(state.selected_option).to eq(0)
    end

    it 'moves selected option up with wraparound' do
      input.up_pressed = true

      state.update

      expect(state.selected_option).to eq(2)
    end

    it 'changes to in-game from the first option' do
      input.action_pressed = true

      state.update

      expect(game.changed_state).to eq(InGameState)
    end

    it 'changes to over from the second option' do
      input.down_pressed = true
      state.update
      input.down_pressed = false
      input.action_pressed = true

      state.update

      expect(game.changed_state).to eq(OverState)
    end

    it 'changes to setup from the third option' do
      input.up_pressed = true
      state.update
      input.up_pressed = false
      input.action_pressed = true

      state.update

      expect(game.changed_state).to eq(SetupState)
    end

    it 'uses base cancel behavior before continue behavior' do
      input.cancel_pressed = true
      input.action_pressed = true

      state.update

      expect(game.changed_state).to eq(SetupState)
    end
  end
end
