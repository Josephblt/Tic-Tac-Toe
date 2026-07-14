# frozen_string_literal: true

require_relative '../states/game_state'
require_relative '../states/goodbye_state'
require_relative '../states/continue_state'
require_relative '../states/over_state'
require_relative '../states/logo_state'
require_relative '../states/setup_state'
require_relative '../states/in_game_state'

# Base class for screen renderers.
class Display
  attr_reader :width,
              :height,
              :renderers

  def initialize(width, height)
    @width = width
    @height = height
    initialize_renderers
  end

  def refresh; end

  private

  def initialize_renderers
    @renderers = {
      ContinueState => TextContinueRenderer.new(self),
      GoodbyeState => TextGoodbyeRenderer.new(self),
      InGameState => TextInGameRenderer.new(self),
      LogoState => TextLogoRenderer.new(self),
      OverState => TextOverRenderer.new(self),
      SetupState => TextSetupRenderer.new(self)
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
end
