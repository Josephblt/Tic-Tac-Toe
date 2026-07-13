# frozen_string_literal: true

require 'js'

# Browser PC input adapter. It preserves the existing Input contract while
# receiving keyboard events from xterm.js through a small JavaScript queue.
class BrowserKeyboardInput < Input
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
