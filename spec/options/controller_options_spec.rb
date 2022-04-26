# frozen_string_literal: true

require 'rspec'
require './src/options/controller_options'

describe ControllerOptions do
  describe 'initialize' do
    it 'initialization HUMAN' do
      controller_option = ControllerOptions.new ControllerOptions::HUMAN
      expect(controller_option.selected_option).to eq(ControllerOptions::HUMAN)
    end

    it 'initialization HARD' do
      controller_option = ControllerOptions.new ControllerOptions::ARTIFICIAL_INTELLIGENCE
      expect(controller_option.selected_option).to eq(ControllerOptions::ARTIFICIAL_INTELLIGENCE)
    end
  end

  describe 'next' do
    it 'plain execution' do
      controller_option = ControllerOptions.new ControllerOptions::HUMAN
      controller_option.next
      expect(controller_option.selected_option).to eq(ControllerOptions::ARTIFICIAL_INTELLIGENCE)
      controller_option.next
      expect(controller_option.selected_option).to eq(ControllerOptions::HUMAN)
    end
  end
end
