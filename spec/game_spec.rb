# frozen_string_literal: true

require 'rspec'
require './src/game'

FakeGameInput = Struct.new(:action_pressed, :cancel_pressed, keyword_init: true) do
  def update
    self
  end
end

class FakeGameDisplay
  attr_reader :finalized,
              :refresh_count,
              :renderers

  def initialize(renderers)
    @renderers = renderers
    @refresh_count = 0
    @finalized = false
  end

  def refresh
    @refresh_count += 1
  end

  def finalize
    @finalized = true
  end
end

class FakeGameRenderer
  attr_reader :drawn_state

  def draw(state)
    @drawn_state = state
  end
end

class FakeTransitionState
  attr_reader :entered,
              :exited

  def enter
    @entered = true
  end

  def exit
    @exited = true
  end
end

describe Game do
  subject(:game) { described_class.new(display, input) }

  let(:input) { FakeGameInput.new(action_pressed: false, cancel_pressed: false) }
  let(:logo_renderer) { FakeGameRenderer.new }
  let(:display) { FakeGameDisplay.new(LogoState => logo_renderer) }

  describe '#initialize' do
    it 'stores default runtime state' do
      expect(game.loop_mode).to eq(Game::LOOP_MODE_EXITABLE)
      expect(game.running).to be false
      expect(game.setup).to be_a(Setup)
    end

    it 'accepts continuous loop mode' do
      game = described_class.new(display, input, loop_mode: Game::LOOP_MODE_CONTINUOUS)

      expect(game.loop_mode).to eq(Game::LOOP_MODE_CONTINUOUS)
    end
  end

  describe '#exit_allowed?' do
    it 'allows exit in exitable loop mode' do
      expect(game.exit_allowed?).to be true
    end

    it 'disallows exit in continuous loop mode' do
      game = described_class.new(display, input, loop_mode: Game::LOOP_MODE_CONTINUOUS)

      expect(game.exit_allowed?).to be false
    end
  end

  describe '#change_to_state' do
    it 'exits the current state and enters the next state' do
      old_state = FakeTransitionState.new
      new_state = FakeTransitionState.new
      state_class = Class.new
      game.instance_variable_set(:@current_game_state, old_state)
      game.instance_variable_set(:@game_states, state_class => new_state)

      game.change_to_state(state_class)

      expect(old_state.exited).to be true
      expect(new_state.entered).to be true
    end
  end

  describe '#start' do
    it 'starts the game at the logo state' do
      game.start

      expect(game).to be_running
      expect(game.instance_variable_get(:@current_game_state)).to be_a(LogoState)
    end
  end

  describe '#update' do
    it 'returns false when the game is not running' do
      expect(game.update).to be false
      expect(display.refresh_count).to eq(0)
    end

    it 'updates, draws, and refreshes the current state while running' do
      game.start

      expect(game.update).to be true
      expect(logo_renderer.drawn_state).to be_a(LogoState)
      expect(display.refresh_count).to eq(1)
    end
  end

  describe '#running?' do
    it 'returns the running flag' do
      expect(game.running?).to be false

      game.start

      expect(game.running?).to be true
    end
  end

  describe '#stop' do
    it 'stops the game' do
      game.start
      game.stop

      expect(game.running?).to be false
    end
  end

  describe '#finalize' do
    it 'finalizes the display' do
      game.finalize

      expect(display.finalized).to be true
    end
  end

  describe '#reset' do
    it 'creates a regular board by default' do
      game.reset

      expect(game.board.player1_symbol).to eq(Symbol::CROSS)
      expect(game.board.player2_symbol).to eq(Symbol::NOUGHT)
    end

    it 'creates an inverted board when symbols are inverted' do
      game.setup.change_symbol_options

      game.reset

      expect(game.board.player1_symbol).to eq(Symbol::NOUGHT)
      expect(game.board.player2_symbol).to eq(Symbol::CROSS)
    end
  end
end
