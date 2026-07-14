# frozen_string_literal: true

require 'tty-cursor'
require_relative '../src/displays/display'
require_relative '../src/renderers/text/text_game_state_renderer'
require_relative '../src/renderers/text/text_continue_renderer'
require_relative '../src/renderers/text/text_goodbye_renderer'
require_relative '../src/renderers/text/text_in_game_renderer'
require_relative '../src/renderers/text/text_logo_renderer'
require_relative '../src/renderers/text/text_setup_renderer'
require_relative '../src/renderers/text/text_over_renderer'

# Renderer for terminal.
class TerminalDisplay < Display
  def initialize
    super(39, 17)
    @cursor = TTY::Cursor
    print @cursor.hide
    print @cursor.clear_screen
    reset_display_string last_display_string: true
    copy_display
  end

  def finalize
    print @cursor.show
  end

  def draw_text(pos_x, pos_y, text)
    text = text.split ''
    i = 0
    text.each do |char|
      @display_matrix[pos_x + i][pos_y] = char
      i += 1
    end
  end

  def refresh
    draw
    copy_display
    reset_display_string
    print @cursor.move_to 0, @height
    print @cursor.clear_line
  end

  private

  def copy_display
    (0..@height - 1).each do |y|
      (0..@width - 1).each do |x|
        @last_display_matrix[x][y] = @display_matrix[x][y]
      end
    end
  end

  def draw
    draw_borders
    (0..@height - 1).each do |y|
      (0..@width - 1).each do |x|
        if @display_matrix[x][y] != @last_display_matrix[x][y]
          print @cursor.move_to x, y
          print @display_matrix[x][y]
        end
      end
    end
  end

  def reset_display_string(last_display_string: false)
    @display_matrix = Array.new(@width) { Array.new(@height) { ' ' } }
    @last_display_matrix = Array.new(@width) { Array.new(@height) { ' ' } } if last_display_string
  end
end
