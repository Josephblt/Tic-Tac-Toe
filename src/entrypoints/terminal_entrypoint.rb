# frozen_string_literal: true

require_relative '../game'
require_relative '../terminal/terminal_display'
require_relative '../terminal/terminal_input'

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
