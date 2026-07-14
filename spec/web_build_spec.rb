# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'rspec'

describe 'web build' do
  before do
    skip 'node is required for the web build' unless system('command -v node > /dev/null')

    FileUtils.rm_rf('dist/web')
  end

  it 'builds a static web package with a bundled Ruby app' do
    stdout, stderr, status = Open3.capture3('npm run build:web')

    expect(status).to be_success, "#{stdout}\n#{stderr}"
    expect(File).to exist('dist/web/index.html')
    expect(File).to exist('dist/web/pc_index.html')
    expect(File).to exist('dist/web/mobile_index.html')
    expect(File).to exist('dist/web/ruby_wasm_boot.js')
    expect(File).to exist('dist/web/app.rb')

    boot_source = File.read('dist/web/ruby_wasm_boot.js')
    app_source = File.read('dist/web/app.rb')

    expect(boot_source).to include('./app.rb')
    expect(app_source).to include('class WebEntrypoint')
    expect(app_source).to include('class WebInput')
    expect(app_source).to include('class WebTerminalDisplay')
    expect(app_source).not_to include('require_relative')
  end
end
