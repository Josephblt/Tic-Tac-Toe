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
    @reader.on(:keybackspace) { @cancel_pressed = true }
    @reader.on(:keypress) do |event|
      on_key_press event
    end
  end

  def update
    reset
    @reader.read_keypress nonblock: true
  end

  private

  def on_key_press(event)
    @left_pressed = true if event.value == 'a'
    @down_pressed = true if event.value == 's'
    @right_pressed = true if event.value == 'd'
    @up_pressed = true if event.value == 'w'
  end
end
