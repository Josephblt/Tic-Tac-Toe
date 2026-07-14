# frozen_string_literal: true

require_relative '../game'
require_relative '../displays/terminal_display'
require_relative '../inputs/terminal_input'

class TerminalEntrypoint
  def self.start
    display = TerminalDisplay.new
    input = TerminalInput.new
    game = Game.new(display, input)
    game.start
    game.update while game.running?
    game.finalize
  end
end

TerminalEntrypoint.start
