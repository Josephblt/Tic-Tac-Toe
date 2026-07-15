# Tic-Tac-Toe

A Ruby implementation of the classic Tic-Tac-Toe game. It can run in the terminal or as a static web build through Ruby WASM.

- Official version: https://josephblt-games.itch.io/tic-tac-toe
- Test version: https://josephblt.github.io/tic-tac-toe/

## Requirements

- Ruby 3.3
- Bundler
- Python 3, or any static file server, for local web testing

Install dependencies:

```sh
bundle install
```

## Run in the Terminal

```sh
ruby src/entrypoints/terminal_entrypoint.rb
```

## Run in the Browser

Build the static web bundle:

```sh
bundle exec rake web:build
```

Serve the generated files:

```sh
python3 -m http.server 8000 --directory dist/web
```

Then open:

```text
http://127.0.0.1:8000
```

## Tests

```sh
bundle exec rspec
```

## Release Package

Create the downloadable web package:

```sh
bundle exec rake web:package
```

The package is written to `dist/tic-tac-toe-web.zip`.
