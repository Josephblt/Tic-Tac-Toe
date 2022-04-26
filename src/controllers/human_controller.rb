# frozen_string_literal: true

require_relative 'controller'

# Describes a controller to be used by a human
class HumanController < Controller
  def update
    @action_pressed = @in_game_state.input.action_pressed
    @down_pressed = @in_game_state.input.down_pressed
    @left_pressed = @in_game_state.input.left_pressed
    @right_pressed = @in_game_state.input.right_pressed
    @up_pressed = @in_game_state.input.up_pressed
  end
end
