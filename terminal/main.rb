# frozen_string_literal: true

require_relative '../src/game'
require_relative 'terminal_display'
require_relative 'terminal_input'

display = TerminalDisplay.new
input = TerminalInput.new
game = Game.new(display, input)
game.start
game.update while game.running?
game.finalize
