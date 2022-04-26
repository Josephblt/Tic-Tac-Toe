# frozen_string_literal: true

# Base class for input detectors.
class Input
  attr_reader :action_pressed,
              :cancel_pressed,
              :down_pressed,
              :left_pressed,
              :right_pressed,
              :up_pressed

  def update; end

  private

  def reset
    @action_pressed = false
    @cancel_pressed = false
    @down_pressed = false
    @left_pressed = false
    @right_pressed = false
    @up_pressed = false
  end
end
