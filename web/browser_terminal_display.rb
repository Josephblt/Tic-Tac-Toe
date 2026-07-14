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

  private

  def write_frame
    @bridge.call(:write, "\e[H#{frame_text}")
  end
end
