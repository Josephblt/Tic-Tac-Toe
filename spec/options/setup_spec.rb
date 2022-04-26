# frozen_string_literal: true

require 'rspec'
require './src/options/setup'

describe Setup do
  describe 'initialize' do
    it 'plain initialization' do
      setup = Setup.new
      expect(setup.ai1_option).to_not be_an_nil
      expect(setup.ai2_option).to_not be_an_nil
      expect(setup.controller1_option).to_not be_an_nil
      expect(setup.controller2_option).to_not be_an_nil
      expect(setup.symbol_option).to_not be_an_nil

      expect(setup.ai1_option.selected_option).to eq(AIOptions::EASY)
      expect(setup.ai2_option.selected_option).to eq(AIOptions::EASY)
      expect(setup.controller1_option.selected_option).to eq(ControllerOptions::HUMAN)
      expect(setup.controller2_option.selected_option).to eq(ControllerOptions::ARTIFICIAL_INTELLIGENCE)
      expect(setup.symbol_option.selected_option).to eq(SymbolOptions::REGULAR)
    end
  end

  describe 'change_ai1_options' do
    it 'plain execution' do
      setup = Setup.new
      setup.change_ai1_options
      expect(setup.ai1_option.selected_option).to eq(AIOptions::HARD)
      setup.change_ai1_options
      expect(setup.ai1_option.selected_option).to eq(AIOptions::IMPOSSIBLE)
      setup.change_ai1_options
      expect(setup.ai1_option.selected_option).to eq(AIOptions::EASY)
    end
  end

  describe 'change_ai2_options' do
    it 'plain execution' do
      setup = Setup.new
      setup.change_ai2_options
      expect(setup.ai2_option.selected_option).to eq(AIOptions::HARD)
      setup.change_ai2_options
      expect(setup.ai2_option.selected_option).to eq(AIOptions::IMPOSSIBLE)
      setup.change_ai2_options
      expect(setup.ai2_option.selected_option).to eq(AIOptions::EASY)
    end
  end

  describe 'change_controller1_options' do
    it 'plain execution' do
      setup = Setup.new
      setup.change_controller1_options
      expect(setup.controller1_option.selected_option).to eq(ControllerOptions::ARTIFICIAL_INTELLIGENCE)
      setup.change_controller1_options
      expect(setup.controller1_option.selected_option).to eq(ControllerOptions::HUMAN)
    end
  end

  describe 'change_controller2_options' do
    it 'plain execution' do
      setup = Setup.new
      setup.change_controller2_options
      expect(setup.controller2_option.selected_option).to eq(ControllerOptions::HUMAN)
      setup.change_controller2_options
      expect(setup.controller2_option.selected_option).to eq(ControllerOptions::ARTIFICIAL_INTELLIGENCE)
    end
  end

  describe 'change_symbol_options' do
    it 'plain execution' do
      setup = Setup.new
      setup.change_symbol_options
      expect(setup.symbol_option.selected_option).to eq(SymbolOptions::INVERTED)
      setup.change_symbol_options
      expect(setup.symbol_option.selected_option).to eq(SymbolOptions::REGULAR)
    end
  end
end
