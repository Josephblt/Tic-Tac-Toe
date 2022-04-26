# frozen_string_literal: true

require_relative '../../options/ai_options'
require_relative '../../options/symbols_options'
require_relative '../../options/controller_options'

# Renderer for Game Logo State
class TerminalSetupRenderer < TerminalGameStateRenderer
  SUBTITLE = 'MATCH SETUP'
  SELECTOR_LEFT = '◀'
  SELECTOR_RIGHT = '▶'
  SYMBOL_OPTIONS = {
    SymbolOptions::REGULAR => "#{SYMBOLS[Symbol::CROSS]} ┃ #{SYMBOLS[Symbol::NOUGHT]}",
    SymbolOptions::INVERTED => "#{SYMBOLS[Symbol::NOUGHT]} ┃ #{SYMBOLS[Symbol::CROSS]}"
  }.freeze

  def initialize(display)
    super(display)
    @blink = 0
  end

  def draw(game_state)
    @blink += 1
    @blink = 0 if @blink > 4
    draw_title 2
    draw_sub_title
    draw_players_header
    draw_controller_option game_state
    draw_symbol_option game_state
    draw_ai_option game_state
    draw_tips
  end

  private

  def ai1_option(game_state)
    controller_option = game_state.game.setup.controller1_option.selected_option
    if controller_option == ControllerOptions::ARTIFICIAL_INTELLIGENCE
      ai_option = AI_OPTIONS[game_state.game.setup.ai1_option.selected_option]
      ai_option = draw_left_selector(ai_option) if game_state.selected_option == 2 && @blink > 2
    else
      ai_option = ''
    end
    ai_option
  end

  def ai2_option(game_state)
    controller_option = game_state.game.setup.controller2_option.selected_option
    if controller_option == ControllerOptions::ARTIFICIAL_INTELLIGENCE
      ai_option = AI_OPTIONS[game_state.game.setup.ai2_option.selected_option]
      ai_option = draw_right_selector(ai_option) if game_state.selected_option == 2 && @blink > 2
    else
      ai_option = ''
    end
    ai_option
  end

  def controller1_option(game_state)
    controller_option = CONTROLLER_OPTIONS[game_state.game.setup.controller1_option.selected_option]
    controller_option = draw_left_selector(controller_option) if game_state.selected_option.zero? && @blink > 2
    controller_option
  end

  def controller2_option(game_state)
    controller_option = CONTROLLER_OPTIONS[game_state.game.setup.controller2_option.selected_option]
    controller_option = draw_right_selector(controller_option) if game_state.selected_option.zero? && @blink > 2
    controller_option
  end

  def draw_ai_option(game_state)
    ai_option = "#{ai1_option game_state} ┃ #{ai2_option game_state}"
    center_index = ai_option.index '┃'
    draw_centered_by_index 10, center_index, ai_option
  end

  def draw_controller_option(game_state)
    controller_option = "#{controller1_option game_state} ┃ #{controller2_option game_state}"
    center_index = controller_option.index '┃'
    draw_centered_by_index 8, center_index, controller_option
  end

  def draw_players_header
    line1 = PLAYERS_HEADER.dup
    line1['-'] = '┃'
    line2 = '━━━━━━━━━━━━━╋━━━━━━━━━━━━━'
    draw_centered 6, line1
    draw_centered 7, line2
  end

  def draw_selectors(option)
    "#{SELECTOR_LEFT} #{option} #{SELECTOR_RIGHT}"
  end

  def draw_left_selector(option)
    "#{SELECTOR_LEFT} #{option}"
  end

  def draw_right_selector(option)
    "#{option} #{SELECTOR_RIGHT}"
  end

  def draw_sub_title
    draw_centered 4, SUBTITLE
  end

  def draw_symbol_option(game_state)
    symbol_options = SYMBOL_OPTIONS[game_state.game.setup.symbol_option.selected_option]
    symbol_options = draw_selectors(symbol_options) if game_state.selected_option == 1 && @blink > 2
    center_index = symbol_options.index '┃'
    draw_centered_by_index 9, center_index, symbol_options
  end
end
