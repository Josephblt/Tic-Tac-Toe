# frozen_string_literal: true

require 'rspec'
require './src/inputs/input'

describe Input do
  subject(:input) { described_class.new }

  describe '#update' do
    it 'does nothing in the base input' do
      expect(input.update).to be_nil
    end
  end

  describe '#reset' do
    it 'clears every pressed input flag' do
      input.instance_variable_set(:@action_pressed, true)
      input.instance_variable_set(:@cancel_pressed, true)
      input.instance_variable_set(:@down_pressed, true)
      input.instance_variable_set(:@left_pressed, true)
      input.instance_variable_set(:@right_pressed, true)
      input.instance_variable_set(:@up_pressed, true)

      input.send(:reset)

      expect(input.action_pressed).to be false
      expect(input.cancel_pressed).to be false
      expect(input.down_pressed).to be false
      expect(input.left_pressed).to be false
      expect(input.right_pressed).to be false
      expect(input.up_pressed).to be false
    end
  end
end
