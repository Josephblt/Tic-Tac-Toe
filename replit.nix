{ pkgs }: {
	deps = [
        pkgs.ruby
        pkgs.solargraph
        pkgs.rufo
        pkgs.rubyPackages.rspec
        pkgs.rubyPackages.simplecov
	];
}