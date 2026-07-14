# frozen_string_literal: true

require 'tty-cursor'
require_relative 'display'
require_relative '../renderers/base_renderer'
require_relative '../renderers/continue_renderer'
require_relative '../renderers/goodbye_renderer'
require_relative '../renderers/in_game_renderer'
require_relative '../renderers/logo_renderer'
require_relative '../renderers/setup_renderer'
require_relative '../renderers/over_renderer'

# Renderer for terminal.
class TerminalDisplay < Display
  def initialize
    super(39, 17)
    @cursor = TTY::Cursor
    print @cursor.hide
    print @cursor.clear_screen
    reset_last_display
    copy_display
  end

  def finalize
    print @cursor.show
  end

  private

  def after_refresh
    copy_display
    print @cursor.move_to 0, @height
    print @cursor.clear_line
  end

  def copy_display
    (0..@height - 1).each do |y|
      (0..@width - 1).each do |x|
        @last_display_matrix[x][y] = @display_matrix[x][y]
      end
    end
  end

  def write_frame
    (0..@height - 1).each do |y|
      (0..@width - 1).each do |x|
        if @display_matrix[x][y] != @last_display_matrix[x][y]
          print @cursor.move_to x, y
          print @display_matrix[x][y]
        end
      end
    end
  end

  def reset_last_display
    @last_display_matrix = Array.new(@width) { Array.new(@height) { ' ' } }
  end
end
