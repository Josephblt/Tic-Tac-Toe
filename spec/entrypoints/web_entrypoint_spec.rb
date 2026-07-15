# frozen_string_literal: true

require 'rspec'

$LOADED_FEATURES << 'js.rb' unless $LOADED_FEATURES.include?('js.rb')

class FakeWebEntrypointGlobal
  attr_reader :cleared_interval,
              :interval_delay,
              :tick

  def initialize(bridge)
    @bridge = bridge
  end

  def [](key)
    raise "unexpected global key: #{key}" unless key == :terminalBridge

    @bridge
  end

  def setInterval(tick, delay)
    @tick = tick
    @interval_delay = delay
    :interval_id
  end

  def clearInterval(interval)
    @cleared_interval = interval
  end
end

module JS
  def self.global
    @global
  end

  def self.global=(global)
    @global = global
  end
end

require './src/entrypoints/web_entrypoint'

class FakeWebEntrypointGame
  LOOP_MODE_CONTINUOUS = :continuous

  attr_reader :display,
              :finalized,
              :input,
              :loop_mode,
              :started,
              :update_count

  def initialize(display, input, options = nil, loop_mode: nil)
    @display = display
    @input = input
    @loop_mode = loop_mode || options.fetch(:loop_mode)
    @running_results = [true, false]
    @started = false
    @update_count = 0
    @finalized = false
  end

  def start
    @started = true
  end

  def update
    @update_count += 1
    @running_results.shift
  end

  def finalize
    @finalized = true
  end
end

describe WebEntrypoint do
  describe '.start' do
    it 'runs the web game on an interval until it stops' do
      bridge = instance_double('TerminalBridge')
      global = FakeWebEntrypointGlobal.new(bridge)
      display = instance_double('WebTerminalDisplay')
      input = instance_double('WebInput')
      game = nil
      input_class = Class.new do
        def initialize(*) end
      end

      JS.global = global
      stub_const('WebTerminalDisplay', Class.new do
        def initialize(*) end
      end)
      allow(WebTerminalDisplay).to receive(:new).with(bridge).and_return(display)
      allow(input_class).to receive(:new).with(bridge).and_return(input)
      stub_const('Game', Class.new(FakeWebEntrypointGame))
      allow(Game).to receive(:new).and_wrap_original do |method, *args, **kwargs|
        game = method.call(*args, **kwargs)
      end

      described_class.start(input_class)
      global.tick.call
      global.tick.call

      expect(game.display).to eq(display)
      expect(game.input).to eq(input)
      expect(game.loop_mode).to eq(FakeWebEntrypointGame::LOOP_MODE_CONTINUOUS)
      expect(game.started).to be true
      expect(game.update_count).to eq(2)
      expect(game.finalized).to be true
      expect(global.interval_delay).to eq(WebEntrypoint::TICK_MS)
      expect(global.cleared_interval).to eq(:interval_id)
    end
  end
end
