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
end
