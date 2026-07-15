# frozen_string_literal: true

require 'tmpdir'
require 'zip'
require './src/build/web_bundle'

describe WebBundle do
  around do |example|
    Dir.mktmpdir do |directory|
      @root_path = Pathname(directory)
      example.run
    end
  end

  describe '#build' do
    it 'builds a static web directory from Ruby dependencies and web assets' do
      write_file('src/symbol.rb', <<~RUBY)
        class Symbol
        end
      RUBY
      write_file('src/game.rb', <<~RUBY)
        require_relative 'symbol'

        class Game
        end
      RUBY
      write_file('src/inputs/input.rb', <<~RUBY)
        class Input
        end
      RUBY
      write_file('src/inputs/web_input.rb', <<~RUBY)
        require 'js'
        require_relative 'input'

        class WebInput < Input
        end
      RUBY
      write_file('src/displays/display.rb', <<~RUBY)
        class Display
        end
      RUBY
      write_file('src/displays/web_terminal_display.rb', <<~RUBY)
        require 'js'
        require_relative 'display'

        class WebTerminalDisplay < Display
        end
      RUBY
      write_file('src/entrypoints/web_entrypoint.rb', <<~RUBY)
        require_relative '../game'
        require_relative '../inputs/web_input'
        require_relative '../displays/web_terminal_display'

        class WebEntrypoint
        end
      RUBY
      write_file('src/web/index.html', '<!doctype html>')
      write_file('src/web/style.css', 'body {}')
      write_file('src/web/web_boot.js', 'await startWebGame();')
      write_file('dist/web/stale.txt', 'stale')

      output_path = described_class.new(root_path: @root_path).build

      expect(output_path).to eq(@root_path.join('dist/web'))
      expect(read_file('dist/web/index.html')).to eq('<!doctype html>')
      expect(read_file('dist/web/style.css')).to eq('body {}')
      expect(read_file('dist/web/web_boot.js')).to eq('await startWebGame();')
      expect(@root_path.join('dist/web/stale.txt')).not_to exist

      app_bundle = read_file('dist/web/app.rb')
      expect(app_bundle).to start_with("# frozen_string_literal: true\n\nmodule Kernel")
      expect(app_bundle).to include("# src/symbol.rb\nclass Symbol")
      expect(app_bundle).to include("# src/game.rb\nrequire_relative 'symbol'")
      expect(app_bundle).to include("# src/entrypoints/web_entrypoint.rb\nrequire_relative '../game'")
      expect(app_bundle.index('# src/symbol.rb')).to be < app_bundle.index('# src/game.rb')
      expect(app_bundle.scan('# src/inputs/input.rb').length).to eq(1)
    end
  end

  describe '#clean' do
    it 'removes the static web directory and release package' do
      write_file('dist/web/app.rb', 'bundle')
      write_file('dist/tic-tac-toe-web.zip', 'package')

      described_class.new(root_path: @root_path).clean

      expect(@root_path.join('dist/web')).not_to exist
      expect(@root_path.join('dist/tic-tac-toe-web.zip')).not_to exist
    end
  end

  describe '#package' do
    it 'builds a release zip from the static web bundle' do
      write_minimal_project

      package_path = described_class.new(root_path: @root_path).package

      expect(package_path).to eq(@root_path.join('dist/tic-tac-toe-web.zip'))
      expect(zip_entries(package_path)).to contain_exactly(
        'app.rb',
        'index.html',
        'style.css',
        'web_boot.js'
      )
      expect(zip_content(package_path, 'index.html')).to eq('<!doctype html>')
    end
  end

  def read_file(path)
    @root_path.join(path).read
  end

  def write_file(path, content)
    full_path = @root_path.join(path)
    FileUtils.mkdir_p(full_path.dirname)
    full_path.write(content)
  end

  def write_minimal_project
    write_file('src/symbol.rb', <<~RUBY)
      class Symbol
      end
    RUBY
    write_file('src/game.rb', <<~RUBY)
      require_relative 'symbol'

      class Game
      end
    RUBY
    write_file('src/inputs/input.rb', <<~RUBY)
      class Input
      end
    RUBY
    write_file('src/inputs/web_input.rb', <<~RUBY)
      require_relative 'input'

      class WebInput < Input
      end
    RUBY
    write_file('src/displays/display.rb', <<~RUBY)
      class Display
      end
    RUBY
    write_file('src/displays/web_terminal_display.rb', <<~RUBY)
      require_relative 'display'

      class WebTerminalDisplay < Display
      end
    RUBY
    write_file('src/entrypoints/web_entrypoint.rb', <<~RUBY)
      require_relative '../game'
      require_relative '../inputs/web_input'
      require_relative '../displays/web_terminal_display'

      class WebEntrypoint
      end
    RUBY
    write_file('src/web/index.html', '<!doctype html>')
    write_file('src/web/style.css', 'body {}')
    write_file('src/web/web_boot.js', 'await startWebGame();')
  end

  def zip_content(path, entry_name)
    Zip::File.open(path) { |zip_file| zip_file.read(entry_name) }
  end

  def zip_entries(path)
    Zip::File.open(path) { |zip_file| zip_file.entries.map(&:name) }
  end
end
