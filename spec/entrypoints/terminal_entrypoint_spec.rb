# frozen_string_literal: true

require 'rspec'
require './src/entrypoints/terminal_entrypoint'

class FakeTerminalEntrypointGame
  attr_reader :display,
              :finalized,
              :input,
              :started,
              :update_count

  def initialize(display, input)
    @display = display
    @input = input
    @running_results = [true, true, false]
    @started = false
    @update_count = 0
    @finalized = false
  end

  def start
    @started = true
  end

  def running?
    @running_results.shift
  end

  def update
    @update_count += 1
  end

  def finalize
    @finalized = true
  end
end

describe TerminalEntrypoint do
  describe '.start' do
    it 'runs a terminal game until it stops' do
      display = instance_double('TerminalDisplay')
      input = instance_double('TerminalInput')
      game = nil

      stub_const('TerminalDisplay', Class.new)
      stub_const('TerminalInput', Class.new)
      allow(TerminalDisplay).to receive(:new).and_return(display)
      allow(TerminalInput).to receive(:new).and_return(input)
      stub_const('Game', Class.new(FakeTerminalEntrypointGame))
      allow(Game).to receive(:new).and_wrap_original do |method, *args|
        game = method.call(*args)
      end

      described_class.start

      expect(game.display).to eq(display)
      expect(game.input).to eq(input)
      expect(game.started).to be true
      expect(game.update_count).to eq(2)
      expect(game.finalized).to be true
    end
  end
end
