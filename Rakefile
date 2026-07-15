# frozen_string_literal: true

require_relative 'src/build/web_bundle'

namespace :web do
  desc 'Build the static web bundle'
  task :build do
    WebBundle.new.build
  end

  desc 'Remove the static web bundle'
  task :clean do
    WebBundle.new.clean
  end

  desc 'Package the static web bundle for release'
  task :package do
    WebBundle.new.package
  end
end
