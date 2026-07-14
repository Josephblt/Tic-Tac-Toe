# frozen_string_literal: true

require 'rspec'
require './src/symbol'
require './src/options/setup'
require './src/states/game_state'
require './src/states/in_game_state'
require './src/states/over_state'
require './src/states/setup_state'

FakeInGameStateInput = Struct.new(:cancel_pressed, keyword_init: true) do
  def update
    self
  end
end

class FakeInGameStateGame
  attr_reader :board,
              :changed_state,
              :reset_called,
              :setup

  def initialize
    @board = Board.new(Symbol::CROSS, Symbol::NOUGHT)
    @setup = Setup.new
    @reset_called = false
  end

  def change_to_state(state)
    @changed_state = state
  end

  def reset
    @reset_called = true
  end
end

class FakeInGameStateController
  attr_accessor :action_pressed,
                :down_pressed,
                :left_pressed,
                :right_pressed,
                :up_pressed
  attr_reader :state,
              :update_count

  def initialize(state)
    @state = state
    @active = false
    @action_pressed = false
    @down_pressed = false
    @left_pressed = false
    @right_pressed = false
    @up_pressed = false
    @update_count = 0
  end

  def active?
    @active
  end

  def activate
    @active = true
  end

  def deactivate
    @active = false
  end

  def update
    @update_count += 1
  end
end

describe InGameState do
  subject(:state) { described_class.new(game, input) }

  let(:game) { FakeInGameStateGame.new }
  let(:input) { FakeInGameStateInput.new(cancel_pressed: false) }

  before do
    stub_const('HumanController', Class.new(FakeInGameStateController))
    stub_const('EasyAIController', Class.new(FakeInGameStateController))
    stub_const('HardAIController', Class.new(FakeInGameStateController))
    stub_const('ImpossibleAIController', Class.new(FakeInGameStateController))
  end

  describe '#enter' do
    it 'resets the game, selected cell, and controllers' do
      state.enter

      expect(game.reset_called).to be true
      expect(state.selected_column).to eq(0)
      expect(state.selected_line).to eq(0)
      expect(state.player1).to be_a(HumanController)
      expect(state.player2).to be_a(EasyAIController)
      expect(state.player1).to be_active
      expect(state.player2).not_to be_active
    end
  end

  describe '#update' do
    before do
      state.enter
    end

    it 'uses base cancel behavior before in-game behavior' do
      input.cancel_pressed = true
      state.player1.action_pressed = true

      state.update

      expect(game.changed_state).to eq(SetupState)
      expect(game.board.empty?(Cell.new(0, 0))).to be true
    end

    it 'updates the active controller' do
      state.update

      expect(state.player1.update_count).to eq(1)
    end

    it 'moves selected column right and wraps' do
      state.player1.right_pressed = true

      3.times { state.update }

      expect(state.selected_column).to eq(0)
    end

    it 'moves selected column left and wraps' do
      state.player1.left_pressed = true

      state.update

      expect(state.selected_column).to eq(2)
    end

    it 'moves selected line down and wraps' do
      state.player1.down_pressed = true

      3.times { state.update }

      expect(state.selected_line).to eq(0)
    end

    it 'moves selected line up and wraps' do
      state.player1.up_pressed = true

      state.update

      expect(state.selected_line).to eq(2)
    end

    it 'marks an empty cell for player one and alternates controller' do
      state.player1.action_pressed = true

      state.update

      expect(game.board.cells[0][0]).to eq(Symbol::CROSS)
      expect(state.player1).not_to be_active
      expect(state.player2).to be_active
    end

    it 'marks an empty cell for player two' do
      state.send(:alternate_controller)
      state.player2.action_pressed = true

      state.update

      expect(game.board.cells[0][0]).to eq(Symbol::NOUGHT)
    end

    it 'does not mark an occupied cell' do
      game.board.convert_player1 Cell.new(0, 0)
      state.player1.action_pressed = true

      state.update

      expect(game.board.cells[0][0]).to eq(Symbol::CROSS)
      expect(state.player1).to be_active
    end

    it 'changes to over when the move ends the game' do
      game.board.convert_player1 Cell.new(0, 0)
      game.board.convert_player1 Cell.new(1, 0)
      state.instance_variable_set(:@selected_column, 2)
      state.instance_variable_set(:@selected_line, 0)
      state.player1.action_pressed = true

      state.update

      expect(game.board.cells[2][0]).to eq(Symbol::CROSS)
      expect(game.changed_state).to eq(OverState)
    end
  end

  describe '#create_ai_controller' do
    it 'creates an easy AI controller' do
      expect(state.send(:create_ai_controller, AIOptions::EASY)).to be_a(EasyAIController)
    end

    it 'creates a hard AI controller' do
      expect(state.send(:create_ai_controller, AIOptions::HARD)).to be_a(HardAIController)
    end

    it 'creates an impossible AI controller by default' do
      expect(state.send(:create_ai_controller, AIOptions::IMPOSSIBLE)).to be_a(ImpossibleAIController)
      expect(state.send(:create_ai_controller, :unknown)).to be_a(ImpossibleAIController)
    end
  end

  describe '#create_controller' do
    it 'creates a human controller' do
      controller = state.send(:create_controller, ControllerOptions::HUMAN, AIOptions::EASY)

      expect(controller).to be_a(HumanController)
    end

    it 'creates an AI controller' do
      controller = state.send(:create_controller, ControllerOptions::ARTIFICIAL_INTELLIGENCE, AIOptions::HARD)

      expect(controller).to be_a(HardAIController)
    end

    it 'creates an AI controller for unknown controller options' do
      controller = state.send(:create_controller, :unknown, AIOptions::EASY)

      expect(controller).to be_a(EasyAIController)
    end
  end
end
