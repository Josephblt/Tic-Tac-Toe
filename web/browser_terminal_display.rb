# frozen_string_literal: true

require 'js'

# Browser-side display adapter. It reuses the shared text state renderers but
# writes complete frames into xterm.js instead of using tty-cursor.
class BrowserTerminalDisplay < Display
  def initialize(bridge)
    @bridge = bridge
    super(39, 17)
    reset_display
    @bridge.call(:write, "\e[?25l\e[2J")
  end

  def finalize
    @bridge.call(:write, "\e[?25h\r\n")
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
    @bridge.call(:write, "\e[H#{frame}")
    reset_display
  end

  private

  def frame
    (0..@height - 1).map do |y|
      (0..@width - 1).map { |x| @display_matrix[x][y] }.join
    end.join("\r\n")
  end

  def reset_display
    @display_matrix = Array.new(@width) { Array.new(@height) { ' ' } }
  end
end
