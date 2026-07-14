import { DefaultRubyVM } from "https://cdn.jsdelivr.net/npm/@ruby/wasm-wasi@2.9.3-2.9.4/dist/browser/+esm";

const sourceFiles = [
  "../../src/symbol.rb",
  "../../src/options/ai_options.rb",
  "../../src/options/controller_options.rb",
  "../../src/options/symbols_options.rb",
  "../../src/options/setup.rb",
  "../../src/board.rb",
  "../../src/inputs/input.rb",
  "../../src/controllers/controller.rb",
  "../../src/controllers/human_controller.rb",
  "../../src/controllers/ai_controller.rb",
  "../../src/states/game_state.rb",
  "../../src/states/goodbye_state.rb",
  "../../src/states/continue_state.rb",
  "../../src/states/over_state.rb",
  "../../src/states/logo_state.rb",
  "../../src/states/setup_state.rb",
  "../../src/states/in_game_state.rb",
  "../../src/displays/game_state_renderer.rb",
  "../../src/renderers/text/text_game_state_renderer.rb",
  "../../src/renderers/text/text_continue_renderer.rb",
  "../../src/renderers/text/text_goodbye_renderer.rb",
  "../../src/renderers/text/text_in_game_renderer.rb",
  "../../src/renderers/text/text_logo_renderer.rb",
  "../../src/renderers/text/text_over_renderer.rb",
  "../../src/renderers/text/text_setup_renderer.rb",
  "../../src/displays/display.rb",
  "../../src/game.rb",
  "../browser_input.rb",
  "../browser_terminal_display.rb",
  "../browser_game_loop.rb"
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

export async function startBrowserGame({
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
    vm.eval("BrowserGameLoop.start(BrowserInput)");
  } catch (error) {
    term.writeln("");
    term.writeln(`Ruby WASM Tic-Tac-Toe failed: ${error.message}`);
    console.error(error);
  }
}
