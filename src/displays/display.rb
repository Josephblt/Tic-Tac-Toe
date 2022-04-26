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

  def create_continue_renderer; end

  def create_goodbye_renderer; end

  def create_in_game_renderer; end

  def create_logo_renderer; end

  def create_over_renderer; end

  def create_setup_renderer; end

  def refresh; end

  private

  def initialize_renderers
    @renderers = {}
    @renderers[ContinueState] = create_continue_renderer
    @renderers[GoodbyeState] = create_goodbye_renderer
    @renderers[InGameState] = create_in_game_renderer
    @renderers[LogoState] = create_logo_renderer
    @renderers[OverState] = create_over_renderer
    @renderers[SetupState] = create_setup_renderer
  end
end
