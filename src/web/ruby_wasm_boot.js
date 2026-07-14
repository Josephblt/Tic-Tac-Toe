import { DefaultRubyVM } from "https://cdn.jsdelivr.net/npm/@ruby/wasm-wasi@2.9.3-2.9.4/dist/browser/+esm";

const sourceFiles = [
  "../symbol.rb",
  "../options/ai_options.rb",
  "../options/controller_options.rb",
  "../options/symbols_options.rb",
  "../options/setup.rb",
  "../board.rb",
  "../inputs/input.rb",
  "../controllers/controller.rb",
  "../controllers/human_controller.rb",
  "../controllers/ai_controller.rb",
  "../states/game_state.rb",
  "../states/goodbye_state.rb",
  "../states/continue_state.rb",
  "../states/over_state.rb",
  "../states/logo_state.rb",
  "../states/setup_state.rb",
  "../states/in_game_state.rb",
  "../displays/game_state_renderer.rb",
  "../renderers/base_renderer.rb",
  "../renderers/continue_renderer.rb",
  "../renderers/goodbye_renderer.rb",
  "../renderers/in_game_renderer.rb",
  "../renderers/logo_renderer.rb",
  "../renderers/over_renderer.rb",
  "../renderers/setup_renderer.rb",
  "../displays/display.rb",
  "../game.rb",
  "../inputs/web_input.rb",
  "../displays/web_terminal_display.rb",
  "../entrypoints/web_entrypoint.rb"
];

const baseTerminalOptions = {
  cols: 41,
  rows: 19,
  convertEol: true,
  cursorBlink: false,
  theme: {
    background: "#111111",
    foreground: "#f2f2f2",
    cursor: "#f2f2f2"
  }
};

const fetchSource = async (path) => {
  const response = await fetch(path, { cache: "no-store" });
  if (!response.ok) {
    throw new Error(`${path}: ${response.status}`);
  }
  return await response.text();
};

const terminalOptions = (options) => ({
  ...baseTerminalOptions,
  ...options,
  theme: {
    ...baseTerminalOptions.theme,
    ...(options.theme || {})
  }
});

export async function startWebGame({
  configureInput,
  focus = false,
  terminal = {},
  waitForFonts = false
}) {
  if (waitForFonts) {
    await document.fonts.ready;
  }

  const term = new Terminal(terminalOptions(terminal));
  const keyQueue = [];

  term.open(document.getElementById("terminal"));
  if (focus) {
    term.focus();
  }
  term.writeln("Loading Ruby WASM Tic-Tac-Toe...");

  configureInput({ keyQueue, term });

  window.terminalBridge = {
    readKey() {
      return keyQueue.shift() || "";
    },
    write(text) {
      term.write(String(text));
    },
    writeln(text) {
      term.writeln(String(text));
    }
  };

  try {
    const wasmResponse = await fetch("https://cdn.jsdelivr.net/npm/@ruby/3.3-wasm-wasi@2.9.3-2.9.4/dist/ruby+stdlib.wasm");
    const wasmModule = await WebAssembly.compileStreaming(wasmResponse);
    const { vm } = await DefaultRubyVM(wasmModule);

    vm.eval(`
      module Kernel
        def require_relative(_path)
          true
        end
      end
    `);

    for (const path of sourceFiles) {
      vm.eval(await fetchSource(path));
    }
    vm.eval("WebEntrypoint.start(WebInput)");
  } catch (error) {
    term.writeln("");
    term.writeln(`Ruby WASM Tic-Tac-Toe failed: ${error.message}`);
    console.error(error);
  }
}
