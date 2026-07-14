# frozen_string_literal: true

require 'rspec'
require './src/states/game_state'
require './src/states/goodbye_state'
require './src/states/logo_state'
require './src/states/setup_state'

FakeLogoStateInput = Struct.new(:action_pressed, :cancel_pressed, keyword_init: true) do
  def update
    self
  end
end

class FakeLogoStateGame
  attr_reader :changed_state

  def initialize(exit_allowed:)
    @exit_allowed = exit_allowed
  end

  def change_to_state(state)
    @changed_state = state
  end

  def exit_allowed?
    @exit_allowed
  end
end

describe LogoState do
  subject(:state) { described_class.new(game, input) }

  let(:input) { FakeLogoStateInput.new(action_pressed: false, cancel_pressed: false) }
  let(:game) { FakeLogoStateGame.new(exit_allowed: true) }

  describe '#update' do
    it 'changes to setup when action is pressed' do
      input.action_pressed = true

      state.update

      expect(game.changed_state).to eq(SetupState)
    end

    it 'changes to goodbye on cancel when exit is allowed' do
      input.cancel_pressed = true

      state.update

      expect(game.changed_state).to eq(GoodbyeState)
    end

    it 'stays on logo on cancel when exit is not allowed' do
      game = FakeLogoStateGame.new(exit_allowed: false)
      state = described_class.new(game, input)
      input.cancel_pressed = true

      state.update

      expect(game.changed_state).to eq(LogoState)
    end

    it 'does not change state without action or cancel' do
      state.update

      expect(game.changed_state).to be_nil
    end
  end
end
