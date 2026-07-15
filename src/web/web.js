import { startWebGame } from "./ruby_wasm_boot.js";

const isTouchDevice = window.matchMedia("(pointer: coarse)").matches || navigator.maxTouchPoints > 0;
const mode = isTouchDevice ? "mobile" : "pc";

document.body.dataset.mode = mode;

const gameKeys = {
  action: "\r",
  back: "\u007F",
  down: "down",
  left: "left",
  right: "right",
  up: "up"
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

const configureKeyboardInput = ({ keyQueue, term }) => {
  term.onKey(({ domEvent }) => {
    const direction = domEvent.code.replace("Arrow", "").toLowerCase();
    const action = domEvent.code === "Enter" ? "action" : direction;
    const input = domEvent.code === "Backspace" ? "back" : action;
    const key = gameKeys[input];

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

const modes = {
  mobile: {
    configureInput: configureTouchInput,
    focus: true,
    terminal: {
      fontFamily: "'Noto Sans Mono', ui-monospace, SFMono-Regular, Menlo, Consolas, monospace",
      fontSize: 13
    },
    waitForFonts: true
  },
  pc: {
    configureInput: configureKeyboardInput,
    focus: true,
    terminal: {
      fontFamily: "'Noto Sans Mono', ui-monospace, SFMono-Regular, Menlo, Consolas, monospace",
      fontSize: 13
    },
    waitForFonts: true
  }
};

loadMobileFont();

await startWebGame(modes[mode]);
