# frozen_string_literal: true

# Base class for in-game control.
class Controller
  attr_reader :action_pressed,
              :down_pressed,
              :left_pressed,
              :right_pressed,
              :up_pressed

  def initialize(in_game_state)
    @in_game_state = in_game_state
    @active = false
    reset
  end

  def active?
    @active
  end

  def activate
    @active = true
  end

  def deactivate
    @active = false
  end

  def update; end

  def reset
    @action_pressed = false
    @down_pressed = false
    @left_pressed = false
    @right_pressed = false
    @up_pressed = false
  end
end
