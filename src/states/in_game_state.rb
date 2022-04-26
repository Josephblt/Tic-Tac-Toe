# frozen_string_literal: true

require_relative '../board'
require_relative '../options/ai_options'
require_relative '../options/controller_options'
require_relative '../controllers/ai_controller'
require_relative '../controllers/human_controller'

# In-game state. Here is where you actually get to play the game.
class InGameState < GameState
  attr_reader :debug_message, :player1, :player2, :selected_column, :selected_line

  def enter
    @game.reset
    @selected_column = 0
    @selected_line = 0
    @player1 = create_controller @game.setup.controller1_option.selected_option, @game.setup.ai1_option.selected_option
    @player2 = create_controller @game.setup.controller2_option.selected_option, @game.setup.ai2_option.selected_option
    alternate_controller
  end

  def update
    super
    update_controller
    update_selected_column
    update_selected_line
    update_action
  end

  private

  def alternate_controller
    if @player1.active?
      @player1.deactivate
      @player2.activate
      @controller = @player2
    else
      @player1.activate
      @player2.deactivate
      @controller = @player1
    end
  end

  def create_ai_controller(ai_option)
    case ai_option
    when AIOptions::EASY
      EasyAIController.new self
    when AIOptions::HARD
      HardAIController.new self
    else
      ImpossibleAIController.new self
    end
  end

  def create_controller(controller_option, ai_option)
    case controller_option
    when ControllerOptions::HUMAN
      create_human_controller
    when ControllerOptions::ARTIFICIAL_INTELLIGENCE
      create_ai_controller ai_option
    else
      create_ai_controller ai_option
    end
  end

  def create_human_controller
    HumanController.new self
  end

  def update_action
    return unless @controller.action_pressed

    cell = Cell.new @selected_column, @selected_line
    return unless @game.board.empty? cell

    if @player1.active?
      @game.board.convert_player1 cell
    else
      @game.board.convert_player2 cell
    end

    update_turn
  end

  def update_controller
    @controller.update
  end

  def update_selected_column
    return unless @controller.left_pressed || @controller.right_pressed

    @selected_column += @controller.right_pressed ? 1 : -1
    @selected_column %= 3
  end

  def update_selected_line
    return unless @controller.down_pressed || @controller.up_pressed

    @selected_line += @controller.down_pressed ? 1 : -1
    @selected_line %= 3
  end

  def update_turn
    if @game.board.game_over?
      @game.change_to_state OverState
    else
      alternate_controller
    end
  end
end
