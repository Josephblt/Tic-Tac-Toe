# frozen_string_literal: true

require_relative '../states/game_state'
require_relative '../states/goodbye_state'
require_relative '../states/continue_state'
require_relative '../states/over_state'
require_relative '../states/logo_state'
require_relative '../states/setup_state'
require_relative '../states/in_game_state'
require_relative '../renderers/base_renderer'
require_relative '../renderers/continue_renderer'
require_relative '../renderers/goodbye_renderer'
require_relative '../renderers/in_game_renderer'
require_relative '../renderers/logo_renderer'
require_relative '../renderers/setup_renderer'
require_relative '../renderers/over_renderer'

# Base class for screen renderers.
class Display
  attr_reader :width,
              :height,
              :renderers

  def initialize(width, height)
    @width = width
    @height = height
    initialize_renderers
    reset_display
  end

  def draw_text(pos_x, pos_y, text)
    text.each_char.with_index do |char, index|
      x = pos_x + index
      next if x.negative? || x >= @width
      next if pos_y.negative? || pos_y >= @height

      @display_matrix[x][pos_y] = char
    end
  end

  def refresh
    draw_borders
    write_frame
    after_refresh
    reset_display
  end

  private

  def initialize_renderers
    @renderers = {
      ContinueState => ContinueRenderer.new(self),
      GoodbyeState => GoodbyeRenderer.new(self),
      InGameState => InGameRenderer.new(self),
      LogoState => LogoRenderer.new(self),
      OverState => OverRenderer.new(self),
      SetupState => SetupRenderer.new(self)
    }
  end

  def draw_borders
    draw_corner_borders
    draw_horizontal_borders
    draw_vertical_borders
  end

  def draw_corner_borders
    @display_matrix[0][0] = '╔'
    @display_matrix[@width - 1][0] = '╗'
    @display_matrix[0][@height - 1] = '╚'
    @display_matrix[@width - 1][@height - 1] = '╝'
  end

  def draw_horizontal_borders
    (1..@width - 2).each do |x|
      @display_matrix[x][0] = '═'
      @display_matrix[x][@height - 1] = '═'
    end
  end

  def draw_vertical_borders
    (1..@height - 2).each do |y|
      @display_matrix[0][y] = '║'
      @display_matrix[@width - 1][y] = '║'
    end
  end

  def after_refresh; end

  def frame_text
    (0..@height - 1).map do |y|
      (0..@width - 1).map { |x| @display_matrix[x][y] }.join
    end.join("\r\n")
  end

  def reset_display
    @display_matrix = Array.new(@width) { Array.new(@height) { ' ' } }
  end

  def write_frame; end
end
