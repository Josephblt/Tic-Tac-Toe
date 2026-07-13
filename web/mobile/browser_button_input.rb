# frozen_string_literal: true

require 'js'

# Browser mobile input adapter. It preserves the existing Input contract while
# receiving touch button events through a small JavaScript queue.
class BrowserButtonInput < Input
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
    when 'a', 'A'
      @left_pressed = true
    when 's', 'S'
      @down_pressed = true
    when 'd', 'D'
      @right_pressed = true
    when 'w', 'W'
      @up_pressed = true
    when "\r", "\n"
      @action_pressed = true
    when "\u007F", "\b"
      @cancel_pressed = true
    end
  end
end
