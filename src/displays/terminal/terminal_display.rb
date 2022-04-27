# frozen_string_literal: true

require 'tty-cursor'
require_relative '../display'
require_relative 'terminal_game_state_renderer'
require_relative 'terminal_continue_renderer'
require_relative 'terminal_goodbye_renderer'
require_relative 'terminal_in_game_renderer'
require_relative 'terminal_logo_renderer'
require_relative 'terminal_setup_renderer'
require_relative 'terminal_over_renderer'

# Renderer for terminal.
class TerminalDisplay < Display
  def initialize
    super(41, 17)
    @cursor = TTY::Cursor
    print @cursor.hide
    print @cursor.clear_screen
    reset_display_string last_display_string: true
    copy_display
  end

  def finalize
    print @cursor.show
  end

  def create_continue_renderer
    TerminalContinueRenderer.new(self)
  end

  def create_goodbye_renderer
    TerminalGoodbyeRenderer.new(self)
  end

  def create_in_game_renderer
    TerminalInGameRenderer.new(self)
  end

  def create_logo_renderer
    TerminalLogoRenderer.new(self)
  end

  def create_over_renderer
    TerminalOverRenderer.new(self)
  end

  def create_setup_renderer
    TerminalSetupRenderer.new(self)
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

  def reset_display_string(last_display_string: false)
    @display_matrix = Array.new(@width) { Array.new(@height) { ' ' } }
    @last_display_matrix = Array.new(@width) { Array.new(@height) { ' ' } } if last_display_string
  end
end
