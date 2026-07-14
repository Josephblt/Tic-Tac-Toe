# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../support', __dir__))

require 'rspec'
require './src/displays/web_terminal_display'

class FakeWebBridge
  attr_reader :calls

  def initialize
    @calls = []
  end

  def call(method_name, *arguments)
    @calls << [method_name, *arguments]
  end
end

describe WebTerminalDisplay do
  subject(:display) { described_class.new(bridge) }

  let(:bridge) { FakeWebBridge.new }

  describe '#initialize' do
    it 'uses web terminal display dimensions' do
      expect(display.width).to eq(39)
      expect(display.height).to eq(17)
    end

    it 'hides the cursor and clears the terminal' do
      display

      expect(bridge.calls).to include([:write, "\e[?25l\e[2J"])
    end
  end

  describe '#finalize' do
    it 'shows the cursor and ends the line' do
      display.finalize

      expect(bridge.calls).to include([:write, "\e[?25h\r\n"])
    end
  end

  describe '#refresh' do
    it 'writes a complete frame at the terminal home position' do
      display.draw_text(2, 1, 'x')
      display.refresh

      expect(bridge.calls).to include(
        [
          :write,
          "\e[H" \
          "╔═════════════════════════════════════╗\r\n" \
          "║ x                                   ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          '╚═════════════════════════════════════╝'
        ]
      )
    end

    it 'resets the frame after writing' do
      display.draw_text(2, 1, 'x')
      display.refresh
      display.refresh

      expect(bridge.calls.last).to eq(
        [
          :write,
          "\e[H" \
          "╔═════════════════════════════════════╗\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          "║                                     ║\r\n" \
          '╚═════════════════════════════════════╝'
        ]
      )
    end
  end
end
