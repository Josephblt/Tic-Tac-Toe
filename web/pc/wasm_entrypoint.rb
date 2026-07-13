# frozen_string_literal: true

require 'js'

bridge = JS.global[:terminalBridge]
display = BrowserTerminalDisplay.new(bridge)
input = BrowserKeyboardInput.new(bridge)
game = Game.new(display, input)
game.start

$tic_tac_toe_tick = proc do
  running = game.update
  unless running
    game.finalize
    JS.global.clearInterval($tic_tac_toe_interval)
  end
end

$tic_tac_toe_interval = JS.global.setInterval($tic_tac_toe_tick, 120)
