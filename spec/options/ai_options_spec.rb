# frozen_string_literal: true

require 'rspec'
require './src/options/ai_options'

describe AIOptions do
  describe 'initialize' do
    it 'initialization EASY' do
      ai_option = AIOptions.new AIOptions::EASY
      expect(ai_option.selected_option).to eq(AIOptions::EASY)
    end

    it 'initialization HARD' do
      ai_option = AIOptions.new AIOptions::HARD
      expect(ai_option.selected_option).to eq(AIOptions::HARD)
    end

    it 'initialization IMPOSSIBLE' do
      ai_option = AIOptions.new AIOptions::IMPOSSIBLE
      expect(ai_option.selected_option).to eq(AIOptions::IMPOSSIBLE)
    end
  end

  describe 'next' do
    it 'plain execution' do
      ai_option = AIOptions.new AIOptions::EASY
      ai_option.next
      expect(ai_option.selected_option).to eq(AIOptions::HARD)
      ai_option.next
      expect(ai_option.selected_option).to eq(AIOptions::IMPOSSIBLE)
      ai_option.next
      expect(ai_option.selected_option).to eq(AIOptions::EASY)
    end
  end
end
