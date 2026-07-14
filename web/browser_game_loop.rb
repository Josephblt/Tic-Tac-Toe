# frozen_string_literal: true

require 'js'

class BrowserGameLoop
  TICK_MS = 120

  def self.start(input_class)
    bridge = JS.global[:terminalBridge]
    display = BrowserTerminalDisplay.new(bridge)
    input = input_class.new(bridge)
    game = Game.new(display, input, loop_mode: Game::LOOP_MODE_CONTINUOUS)
    game.start

    interval = nil
    tick = proc do
      running = game.update
      unless running
        game.finalize
        JS.global.clearInterval(interval)
      end
    end

    interval = JS.global.setInterval(tick, TICK_MS)
  end
end
