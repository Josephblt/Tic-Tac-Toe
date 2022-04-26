# frozen_string_literal: true

# Setup state. Here it is possible to setup a match.
class SetupState < GameState
  # fzzzxzaaqqqwredcgbvjmmaaaaaaaaaaaaaaaarrrrtin

  attr_reader :selected_option

  def enter
    @selected_option = 0
  end

  def update
    super
    update_selected_option
    update_controller1_option
    update_controller2_option
    update_symbol_option
    update_ai1_option
    update_ai2_option
    @game.change_to_state InGameState if input.action_pressed
  end

  private

  def update_ai1_option
    return unless @selected_option == 2
    return unless input.left_pressed

    @game.setup.change_ai1_options
  end

  def update_ai2_option
    return unless @selected_option == 2
    return unless input.right_pressed

    @game.setup.change_ai2_options
  end

  def update_controller1_option
    return unless @selected_option.zero?
    return unless input.left_pressed

    @game.setup.change_controller1_options
  end

  def update_controller2_option
    return unless @selected_option.zero?
    return unless input.right_pressed

    @game.setup.change_controller2_options
  end

  def update_selected_option
    return unless @input.down_pressed || input.up_pressed

    @selected_option += input.down_pressed ? 1 : -1
    ctrl1_option = @game.setup.controller1_option.selected_option
    ctrl2_option = @game.setup.controller2_option.selected_option
    options_size = ctrl1_option == ControllerOptions::HUMAN && ctrl2_option == ControllerOptions::HUMAN ? 2 : 3
    @selected_option %= options_size
  end

  def update_symbol_option
    return unless @selected_option == 1
    return unless input.left_pressed || input.right_pressed

    @game.setup.change_symbol_options
  end
end
