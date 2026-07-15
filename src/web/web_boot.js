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

const terminalOptions = {
  cols: 39,
  rows: 17
};

const fetchSource = async (path) => {
  const response = await fetch(path, { cache: "no-store" });
  if (!response.ok) {
    throw new Error(`${path}: ${response.status}`);
  }
  return await response.text();
};

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
      document.activeElement.blur();
      keyQueue.push(gameKeys[button.dataset.input]);
    });
  });
};

const startWebGame = async () => {
  await document.fonts.ready;

  const terminalElement = document.getElementById("terminal");
  const term = new Terminal(terminalOptions);
  const keyQueue = [];

  term.open(terminalElement);
  if (!isTouchDevice) {
    term.focus();
  }
  term.writeln("Loading Ruby WASM Tic-Tac-Toe...");

  const configureInput = isTouchDevice ? configureTouchInput : configureKeyboardInput;
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
    vm.eval("WebEntrypoint.start");
  } catch (error) {
    term.writeln("");
    term.writeln(`Ruby WASM Tic-Tac-Toe failed: ${error.message}`);
    console.error(error);
  }
};

await startWebGame();
