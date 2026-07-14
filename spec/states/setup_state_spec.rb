# frozen_string_literal: true

require 'rspec'
require './src/options/setup'
require './src/states/game_state'
require './src/states/in_game_state'
require './src/states/logo_state'
require './src/states/setup_state'

FakeSetupStateInput = Struct.new(
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

class FakeSetupStateGame
  attr_reader :changed_state,
              :setup

  def initialize
    @setup = Setup.new
  end

  def change_to_state(state)
    @changed_state = state
  end
end

describe SetupState do
  subject(:state) { described_class.new(game, input) }

  let(:game) { FakeSetupStateGame.new }
  let(:input) do
    FakeSetupStateInput.new(
      action_pressed: false,
      cancel_pressed: false,
      down_pressed: false,
      left_pressed: false,
      right_pressed: false,
      up_pressed: false
    )
  end

  describe '#enter' do
    it 'selects the first setup option' do
      state.enter

      expect(state.selected_option).to eq(0)
    end
  end

  describe '#update' do
    before do
      state.enter
    end

    it 'moves selected option down with three options when an AI player is selected' do
      input.down_pressed = true

      3.times { state.update }

      expect(state.selected_option).to eq(0)
    end

    it 'moves selected option up with wraparound' do
      input.up_pressed = true

      state.update

      expect(state.selected_option).to eq(2)
    end

    it 'uses two setup options when both players are human' do
      game.setup.change_controller2_options
      input.down_pressed = true

      2.times { state.update }

      expect(state.selected_option).to eq(0)
    end

    it 'changes player one controller option with left on controller selection' do
      input.left_pressed = true

      state.update

      expect(game.setup.controller1_option.selected_option).to eq(ControllerOptions::ARTIFICIAL_INTELLIGENCE)
    end

    it 'changes player two controller option with right on controller selection' do
      input.right_pressed = true

      state.update

      expect(game.setup.controller2_option.selected_option).to eq(ControllerOptions::HUMAN)
    end

    it 'changes symbol options with left or right on symbol selection' do
      state.instance_variable_set(:@selected_option, 1)
      input.left_pressed = true

      state.update

      expect(game.setup.symbol_option.selected_option).to eq(SymbolOptions::INVERTED)

      input.left_pressed = false
      input.right_pressed = true
      state.update

      expect(game.setup.symbol_option.selected_option).to eq(SymbolOptions::REGULAR)
    end

    it 'changes player one AI option with left on AI selection' do
      state.instance_variable_set(:@selected_option, 2)
      input.left_pressed = true

      state.update

      expect(game.setup.ai1_option.selected_option).to eq(AIOptions::HARD)
    end

    it 'changes player two AI option with right on AI selection' do
      state.instance_variable_set(:@selected_option, 2)
      input.right_pressed = true

      state.update

      expect(game.setup.ai2_option.selected_option).to eq(AIOptions::HARD)
    end

    it 'changes to in-game when action is pressed' do
      input.action_pressed = true

      state.update

      expect(game.changed_state).to eq(InGameState)
    end

    it 'changes to logo on cancel before setup behavior' do
      input.cancel_pressed = true
      input.action_pressed = true

      state.update

      expect(game.changed_state).to eq(LogoState)
    end
  end
end
