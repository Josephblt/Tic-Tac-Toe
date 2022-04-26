# frozen_string_literal: true

require_relative 'displays/terminal/terminal_display'
require_relative 'game'
require_relative 'inputs/terminal_input'

display = TerminalDisplay.new
input = TerminalInput.new
game = Game.new(display, input)
game.play
