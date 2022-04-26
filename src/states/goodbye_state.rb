# frozen_string_literal: true

# Goodbye state. Shows a nice goodbye message.
class GoodbyeState < GameState
  def update
    @game.quit
  end
end
