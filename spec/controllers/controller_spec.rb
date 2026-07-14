# frozen_string_literal: true

require 'rspec'
require './src/controllers/controller'

describe Controller do
  subject(:controller) { described_class.new(in_game_state) }

  let(:in_game_state) { instance_double('InGameState') }

  describe '#initialize' do
    it 'starts inactive' do
      expect(controller).not_to be_active
    end

    it 'starts with no pressed controls' do
      expect(controller.action_pressed).to be false
      expect(controller.down_pressed).to be false
      expect(controller.left_pressed).to be false
      expect(controller.right_pressed).to be false
      expect(controller.up_pressed).to be false
    end
  end

  describe '#activate' do
    it 'marks the controller active' do
      controller.activate

      expect(controller).to be_active
    end
  end

  describe '#deactivate' do
    it 'marks the controller inactive' do
      controller.activate
      controller.deactivate

      expect(controller).not_to be_active
    end
  end

  describe '#update' do
    it 'does not change the base controller state' do
      controller.activate

      expect { controller.update }.not_to change { controller.active? }
    end
  end

  describe '#reset' do
    it 'clears every pressed control' do
      controller.instance_variable_set(:@action_pressed, true)
      controller.instance_variable_set(:@down_pressed, true)
      controller.instance_variable_set(:@left_pressed, true)
      controller.instance_variable_set(:@right_pressed, true)
      controller.instance_variable_set(:@up_pressed, true)

      controller.reset

      expect(controller.action_pressed).to be false
      expect(controller.down_pressed).to be false
      expect(controller.left_pressed).to be false
      expect(controller.right_pressed).to be false
      expect(controller.up_pressed).to be false
    end
  end
end
