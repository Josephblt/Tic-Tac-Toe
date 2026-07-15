# frozen_string_literal: true

require 'fileutils'
require 'pathname'

# Builds the browser-playable static bundle for Ruby WASM hosting.
class WebBundle
  HEADER = <<~RUBY
    # frozen_string_literal: true

    module Kernel
      def require_relative(_path)
        true
      end
    end

  RUBY

  WEB_FILES = %w[
    index.html
    style.css
    web_boot.js
  ].freeze

  attr_reader :entrypoint_path,
              :output_path,
              :root_path,
              :source_path,
              :web_files

  def initialize(root_path: Pathname.pwd,
                 source_path: 'src',
                 output_path: 'dist/web',
                 entrypoint_path: 'src/entrypoints/web_entrypoint.rb',
                 web_files: WEB_FILES)
    @root_path = Pathname(root_path)
    @source_path = @root_path.join(source_path)
    @output_path = @root_path.join(output_path)
    @entrypoint_path = @root_path.join(entrypoint_path)
    @web_files = web_files
  end

  def build
    clean
    FileUtils.mkdir_p(output_path)
    copy_web_files
    write_app_bundle
    output_path
  end

  def clean
    FileUtils.rm_rf(output_path)
  end

  private

  def app_bundle
    HEADER + ordered_source_paths.map { |path| bundled_source(path) }.join("\n\n") + "\n"
  end

  def bundled_source(path)
    "# #{relative_path(path)}\n#{path.read}"
  end

  def copy_web_files
    web_files.each do |file|
      FileUtils.cp(source_path.join('web', file), output_path.join(file))
    end
  end

  def ordered_source_paths
    visited = {}
    collect_source_paths(entrypoint_path, visited)
  end

  def collect_source_paths(path, visited)
    return [] if visited[path]

    visited[path] = true
    dependency_paths(path).flat_map { |dependency| collect_source_paths(dependency, visited) } + [path]
  end

  def dependency_paths(path)
    path.read.lines.filter_map do |line|
      match = line.match(/^\s*require_relative\s+['"]([^'"]+)['"]/)
      resolve_dependency(path, match[1]) if match
    end
  end

  def resolve_dependency(path, dependency)
    dependency_path = path.dirname.join(dependency)
    dependency_path = dependency_path.sub_ext('.rb') if dependency_path.extname.empty?
    dependency_path.cleanpath
  end

  def relative_path(path)
    path.relative_path_from(root_path)
  end

  def write_app_bundle
    output_path.join('app.rb').write(app_bundle)
  end
end
