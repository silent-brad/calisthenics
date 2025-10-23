/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./templates/**/*.html",
    "./posts/**/*.typ",
    "./*.html"
  ],
  theme: {
    extend: {},
  },
  plugins: [],
  corePlugins: {
    // Disable some core plugins to avoid conflicts with Pico.css
    preflight: false,
  }
}
