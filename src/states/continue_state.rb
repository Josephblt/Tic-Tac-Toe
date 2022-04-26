# frozen_string_literal: true

# Game continue state. Choose to play again or setup a new match.
class ContinueState < GameState
  attr_reader :selected_option

  def enter
    @selected_option = 0
  end

  def update
    super
    update_selected_option
    update_action
  end

  private

  def update_action
    return unless @input.action_pressed

    if @selected_option.zero?
      @game.change_to_state InGameState
    elsif @selected_option == 1
      @game.change_to_state OverState
    elsif @selected_option == 2
      @game.change_to_state SetupState
    end
  end

  def update_selected_option
    return unless @input.down_pressed || @input.up_pressed

    @selected_option += @input.down_pressed ? 1 : -1
    @selected_option %= 3
  end
end
