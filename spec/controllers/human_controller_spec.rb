# frozen_string_literal: true

require 'rspec'
require './src/controllers/human_controller'

describe HumanController do
  subject(:controller) { described_class.new(in_game_state) }

  InputState = Struct.new(
    :action_pressed,
    :down_pressed,
    :left_pressed,
    :right_pressed,
    :up_pressed,
    keyword_init: true
  )

  let(:in_game_state) { instance_double('InGameState', input: input) }

  describe '#update' do
    context 'when input controls are pressed' do
      let(:input) do
        InputState.new(
          action_pressed: true,
          down_pressed: true,
          left_pressed: true,
          right_pressed: true,
          up_pressed: true
        )
      end

      it 'copies pressed controls from input' do
        controller.update

        expect(controller.action_pressed).to be true
        expect(controller.down_pressed).to be true
        expect(controller.left_pressed).to be true
        expect(controller.right_pressed).to be true
        expect(controller.up_pressed).to be true
      end
    end

    context 'when input controls are not pressed' do
      let(:input) do
        InputState.new(
          action_pressed: false,
          down_pressed: false,
          left_pressed: false,
          right_pressed: false,
          up_pressed: false
        )
      end

      it 'copies unpressed controls from input' do
        controller.instance_variable_set(:@action_pressed, true)
        controller.instance_variable_set(:@down_pressed, true)
        controller.instance_variable_set(:@left_pressed, true)
        controller.instance_variable_set(:@right_pressed, true)
        controller.instance_variable_set(:@up_pressed, true)

        controller.update

        expect(controller.action_pressed).to be false
        expect(controller.down_pressed).to be false
        expect(controller.left_pressed).to be false
        expect(controller.right_pressed).to be false
        expect(controller.up_pressed).to be false
      end
    end
  end
end
