import { DefaultRubyVM } from "https://cdn.jsdelivr.net/npm/@ruby/wasm-wasi@2.9.3-2.9.4/dist/browser/+esm";

const appSourcePath = "./app.rb";

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

    vm.eval(await fetchSource(appSourcePath));
    vm.eval("WebEntrypoint.start(WebInput)");
  } catch (error) {
    term.writeln("");
    term.writeln(`Ruby WASM Tic-Tac-Toe failed: ${error.message}`);
    console.error(error);
  }
}
