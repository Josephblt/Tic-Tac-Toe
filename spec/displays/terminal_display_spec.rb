# frozen_string_literal: true

require 'rspec'
require './src/displays/terminal_display'

describe TerminalDisplay do
  let(:fake_cursor) do
    Class.new do
      def self.hide
        '<hide>'
      end

      def self.clear_screen
        '<clear_screen>'
      end

      def self.show
        '<show>'
      end

      def self.move_to(x, y)
        "<move_to:#{x},#{y}>"
      end

      def self.clear_line
        '<clear_line>'
      end
    end
  end

  before do
    stub_const('TTY::Cursor', fake_cursor)
  end

  describe '#initialize' do
    it 'uses terminal display dimensions' do
      display = nil

      expect { display = described_class.new }.to output.to_stdout

      expect(display.width).to eq(39)
      expect(display.height).to eq(17)
    end

    it 'hides the cursor and clears the terminal' do
      expect { described_class.new }.to output('<hide><clear_screen>').to_stdout
    end
  end

  describe '#finalize' do
    it 'shows the cursor' do
      display = nil
      expect { display = described_class.new }.to output.to_stdout

      expect { display.finalize }.to output('<show>').to_stdout
    end
  end

  describe '#refresh' do
    it 'prints changed cells and clears the command line' do
      display = nil
      expect { display = described_class.new }.to output.to_stdout

      expect { display.refresh }.to output(
        a_string_including(
          '<move_to:0,0>╔',
          '<move_to:38,0>╗',
          '<move_to:0,16>╚',
          '<move_to:38,16>╝',
          '<move_to:0,17><clear_line>'
        )
      ).to_stdout
    end

    it 'does not reprint unchanged cells on the next refresh' do
      display = nil
      expect { display = described_class.new }.to output.to_stdout
      expect { display.refresh }.to output.to_stdout

      expect { display.refresh }.to output('<move_to:0,17><clear_line>').to_stdout
    end
  end
end
