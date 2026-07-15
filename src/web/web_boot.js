import { DefaultRubyVM } from "https://cdn.jsdelivr.net/npm/@ruby/wasm-wasi@2.9.3-2.9.4/dist/browser/+esm";

const appSourcePath = "./app.rb";
const isTouchDevice = window.matchMedia("(pointer: coarse)").matches || navigator.maxTouchPoints > 0;
const mode = isTouchDevice ? "mobile" : "pc";

document.body.dataset.mode = mode;

const gameKeys = {
  ArrowLeft: "left",
  ArrowRight: "right",
  ArrowDown: "down",
  ArrowUp: "up",
  Enter: "\r",
  Backspace: "\u007F"
};

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

const appendLink = (attributes) => {
  const link = document.createElement("link");
  Object.entries(attributes).forEach(([name, value]) => {
    link.setAttribute(name, value);
  });
  document.head.appendChild(link);
};

const loadMobileFont = () => {
  appendLink({
    href: "https://fonts.googleapis.com",
    rel: "preconnect"
  });
  appendLink({
    crossorigin: "",
    href: "https://fonts.gstatic.com",
    rel: "preconnect"
  });
  appendLink({
    href: "https://fonts.googleapis.com/css2?family=Noto+Sans+Mono:wght@400;700&display=swap",
    rel: "stylesheet"
  });
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

const configureKeyboardInput = ({ keyQueue, term }) => {
  term.onKey(({ domEvent }) => {
    const key = gameKeys[domEvent.code];

    if (key) {
      keyQueue.push(key);
      domEvent.preventDefault();
    }
  });
};

const configureTouchInput = ({ keyQueue }) => {
  const controls = document.getElementById("controls");
  controls.hidden = false;
  controls.querySelectorAll("button").forEach((button) => {
    button.addEventListener("pointerdown", (event) => {
      event.preventDefault();
      keyQueue.push(gameKeys[button.dataset.input]);
    });
  });
};

const sharedMode = {
  focus: true,
  terminal: {
    fontFamily: "'Noto Sans Mono', ui-monospace, SFMono-Regular, Menlo, Consolas, monospace",
    fontSize: 13
  },
  waitForFonts: true
};

const modes = {
  mobile: {
    ...sharedMode,
    configureInput: configureTouchInput
  },
  pc: {
    ...sharedMode,
    configureInput: configureKeyboardInput
  }
};

const startWebGame = async ({
  configureInput,
  focus = false,
  terminal = {},
  waitForFonts = false
}) => {
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
};

loadMobileFont();
await startWebGame(modes[mode]);
