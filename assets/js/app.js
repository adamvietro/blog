// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken }
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()
window.liveSocket = liveSocket // <- This makes it accessible in the console

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Vendored (see assets/vendor/) rather than `import "prismjs"`, since this
// project has no assets/package.json for esbuild to resolve an npm package
// from during the production build. Core bundle + autoloader plugin: any
// language Prism supports gets its grammar fetched on demand, instead of us
// having to import each language's component up front.
import "../vendor/prism-core.js"
import "../vendor/prism-autoloader.js"

window.Prism.plugins.autoloader.languages_path =
  "https://cdnjs.cloudflare.com/ajax/libs/prism/1.30.0/components/"

document.addEventListener("DOMContentLoaded", () => {
  window.Prism.highlightAll()
})

// Theme toggle (light/dark/system) — see the blocking script in root.html.heex's
// <head> for the pre-paint theme application that avoids a flash of the wrong theme.
function currentThemeChoice() {
  try {
    return localStorage.getItem("theme") || "system"
  } catch (e) {
    return "system"
  }
}

function applyTheme(choice) {
  const isDark =
    choice === "dark" ||
    (choice === "system" && window.matchMedia("(prefers-color-scheme: dark)").matches)
  document.documentElement.classList.toggle("dark", isDark)
}

function markActiveThemeButton(choice) {
  document.querySelectorAll(".theme-toggle-btn").forEach(btn => {
    btn.setAttribute("data-active", btn.dataset.themeChoice === choice ? "true" : "false")
  })
}

function initThemeToggle() {
  markActiveThemeButton(currentThemeChoice())

  document.querySelectorAll(".theme-toggle-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      const choice = btn.dataset.themeChoice
      try {
        localStorage.setItem("theme", choice)
      } catch (e) {}
      applyTheme(choice)
      markActiveThemeButton(choice)
    })
  })
}

document.addEventListener("DOMContentLoaded", initThemeToggle)

window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", () => {
  if (currentThemeChoice() === "system") applyTheme("system")
})