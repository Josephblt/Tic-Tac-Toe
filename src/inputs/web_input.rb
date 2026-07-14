# frozen_string_literal: true

require 'js'
require_relative 'input'

# Web input adapter. The JavaScript side normalizes keyboard and button
# events into the same queue values before Ruby reads them.
class WebInput < Input
  def initialize(bridge)
    super()
    @bridge = bridge
    reset
  end

  def update
    reset

    loop do
      key = @bridge.call(:readKey).to_s
      break if key.empty?

      on_key_press(key)
    end
  end

  private

  def on_key_press(key)
    case key
    when 'left'
      @left_pressed = true
    when 'down'
      @down_pressed = true
    when 'right'
      @right_pressed = true
    when 'up'
      @up_pressed = true
    when "\r", "\n"
      @action_pressed = true
    when "\u007F", "\b"
      @cancel_pressed = true
    end
  end
end
