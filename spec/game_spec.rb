# frozen_string_literal: true

require 'rspec'
require './src/game'

describe Game do
  describe 'initialize' do
    it 'initialization with Mocks' do
      display_mock = TerminalDisplay.new
      input_mock = TerminalInput.new
      game = Game.new display_mock, input_mock
      expect(game).to have_attributes(display: display_mock)
      expect(game).to have_attributes(input: input_mock)
    end
  end
end
