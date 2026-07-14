# frozen_string_literal: true

require 'rspec'
require './src/inputs/terminal_input'

class FakeTerminalReader
  attr_reader :handlers,
              :read_keypress_options

  def initialize
    @handlers = {}
  end

  def on(event, &handler)
    @handlers[event] = handler
  end

  def read_keypress(**options)
    @read_keypress_options = options
  end
end

FakeTerminalKeyPress = Struct.new(:value, keyword_init: true)

describe TerminalInput do
  subject(:input) { described_class.new }

  let(:reader) { FakeTerminalReader.new }

  before do
    reader_class = Class.new
    allow(reader_class).to receive(:new).and_return(reader)
    stub_const('TTY::Reader', reader_class)
  end

  describe '#initialize' do
    it 'starts with no pressed inputs' do
      expect(input.action_pressed).to be false
      expect(input.cancel_pressed).to be false
      expect(input.down_pressed).to be false
      expect(input.left_pressed).to be false
      expect(input.right_pressed).to be false
      expect(input.up_pressed).to be false
    end

    it 'registers terminal key handlers' do
      input

      expect(reader.handlers.keys).to contain_exactly(
        :keyreturn,
        :keybackspace,
        :keyleft,
        :keydown,
        :keyright,
        :keyup,
        :keypress
      )
    end
  end

  describe '#update' do
    it 'resets stale input and reads one nonblocking keypress' do
      input.instance_variable_set(:@action_pressed, true)

      input.update

      expect(input.action_pressed).to be false
      expect(reader.read_keypress_options).to eq(nonblock: true)
    end
  end

  describe 'registered key handlers' do
    it 'sets action for return' do
      input

      reader.handlers[:keyreturn].call

      expect(input.action_pressed).to be true
    end

    it 'sets cancel for backspace' do
      input

      reader.handlers[:keybackspace].call

      expect(input.cancel_pressed).to be true
    end

    it 'sets direction flags for named arrow keys' do
      input

      reader.handlers[:keyleft].call
      reader.handlers[:keydown].call
      reader.handlers[:keyright].call
      reader.handlers[:keyup].call

      expect(input.left_pressed).to be true
      expect(input.down_pressed).to be true
      expect(input.right_pressed).to be true
      expect(input.up_pressed).to be true
    end

    it 'routes raw keypress events through keypress handling' do
      input

      reader.handlers[:keypress].call(FakeTerminalKeyPress.new(value: "\e[D"))

      expect(input.left_pressed).to be true
    end
  end

  describe '#on_key_press' do
    it 'sets direction flags for raw arrow key escape values' do
      input

      input.send(:on_key_press, FakeTerminalKeyPress.new(value: "\e[D"))
      input.send(:on_key_press, FakeTerminalKeyPress.new(value: "\e[B"))
      input.send(:on_key_press, FakeTerminalKeyPress.new(value: "\e[C"))
      input.send(:on_key_press, FakeTerminalKeyPress.new(value: "\e[A"))

      expect(input.left_pressed).to be true
      expect(input.down_pressed).to be true
      expect(input.right_pressed).to be true
      expect(input.up_pressed).to be true
    end
  end
end
