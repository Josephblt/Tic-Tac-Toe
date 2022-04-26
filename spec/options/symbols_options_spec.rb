# frozen_string_literal: true

require 'rspec'
require './src/options/symbols_options'

describe SymbolOptions do
  describe 'initialize' do
    it 'plain initialization' do
      symbols_option = SymbolOptions.new
      expect(symbols_option.selected_option).to eq(SymbolOptions::REGULAR)
    end
  end

  describe 'next' do
    it 'plain execution' do
      symbols_option = SymbolOptions.new
      symbols_option.next
      expect(symbols_option.selected_option).to eq(SymbolOptions::INVERTED)
      symbols_option.next
      expect(symbols_option.selected_option).to eq(SymbolOptions::REGULAR)
    end
  end
end
