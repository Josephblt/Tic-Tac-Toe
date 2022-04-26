# frozen_string_literal: true

require 'tty-reader'
require_relative 'input'

# Non-interrupting key input detector for terminal.
class TerminalInput < Input
  def initialize
    super
    reset
    @reader = TTY::Reader.new
    @reader.on(:keyreturn) { @action_pressed = true }
    @reader.on(:keyescape) { @cancel_pressed = true }
    @reader.on(:keydown) { @down_pressed = true }
    @reader.on(:keyleft) { @left_pressed = true }
    @reader.on(:keyright) { @right_pressed = true }
    @reader.on(:keyup) { @up_pressed = true }
  end

  def update
    reset
    @reader.read_keypress nonblock: true
  end
end
