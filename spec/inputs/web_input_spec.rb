# frozen_string_literal: true

require 'rspec'

$LOADED_FEATURES << 'js.rb' unless $LOADED_FEATURES.include?('js.rb')

require './src/inputs/web_input'

class FakeWebInputBridge
  attr_reader :read_count

  def initialize(keys)
    @keys = keys
    @read_count = 0
  end

  def call(method_name)
    raise "unexpected bridge method: #{method_name}" unless method_name == :readKey

    @read_count += 1
    @keys.shift || ''
  end
end

describe WebInput do
  subject(:input) { described_class.new(bridge) }

  let(:bridge) { FakeWebInputBridge.new(keys) }

  describe '#initialize' do
    let(:keys) { [] }

    it 'starts with no pressed inputs' do
      expect(input.action_pressed).to be false
      expect(input.cancel_pressed).to be false
      expect(input.down_pressed).to be false
      expect(input.left_pressed).to be false
      expect(input.right_pressed).to be false
      expect(input.up_pressed).to be false
    end
  end

  describe '#update' do
    context 'when no keys are queued' do
      let(:keys) { [] }

      it 'resets stale input and stops after an empty read' do
        input.instance_variable_set(:@action_pressed, true)

        input.update

        expect(input.action_pressed).to be false
        expect(bridge.read_count).to eq(1)
      end
    end

    context 'when direction keys are queued' do
      let(:keys) { %w[left down right up] }

      it 'sets direction flags and drains the queue' do
        input.update

        expect(input.left_pressed).to be true
        expect(input.down_pressed).to be true
        expect(input.right_pressed).to be true
        expect(input.up_pressed).to be true
        expect(bridge.read_count).to eq(5)
      end
    end

    context 'when action and cancel keys are queued' do
      let(:keys) { ["\r", "\n", "\u007F", "\b"] }

      it 'sets action and cancel flags' do
        input.update

        expect(input.action_pressed).to be true
        expect(input.cancel_pressed).to be true
      end
    end

    context 'when an unknown key is queued' do
      let(:keys) { ['unknown'] }

      it 'ignores unknown keys' do
        input.update

        expect(input.action_pressed).to be false
        expect(input.cancel_pressed).to be false
        expect(input.down_pressed).to be false
        expect(input.left_pressed).to be false
        expect(input.right_pressed).to be false
        expect(input.up_pressed).to be false
      end
    end
  end
end
