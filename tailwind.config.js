const colors = require('tailwindcss/colors');

module.exports = {
  purge: [
    'app/views/**/*.html.erb',
    'app/models/**/*.rb',
    'app/javascript/**/*.js',
    'app/assets/javascripts/**/*.js'
  ],
  safelist: [
    // Toggle switch classes
    'toggle-switch',
    'toggle-dot',
    'bg-notebook-blue',
    'translate-x-5',
    'translate-x-0',
    // Icon rotation animation
    'transform',
    'rotate-90',
    'group-hover:rotate-90',
    'transition-transform',
    'duration-200',
    // Color classes used by Flora and other content types
    'bg-lime-700',
    'text-lime-700',
    'text-lighten-2',
    'lighten-2',
    'teal',
    'teal-text',
    // Ensure pseudo-element classes aren't purged if used elsewhere
    { pattern: /^after:/ },
    { pattern: /^peer/ },
    // Safelist all color variations that might be used dynamically
    { pattern: /^bg-(red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose|brown)-(50|100|200|300|400|500|600|700|800|900)$/ },
    { pattern: /^text-(red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose|brown)-(50|100|200|300|400|500|600|700|800|900)$/ },
  ],
  theme: {
    colors: {
      // Include all default Tailwind colors
      transparent: 'transparent',
      current: 'currentColor',
      black: colors.black,
      white: colors.white,
      gray: colors.gray,
      red: colors.red,
      yellow: colors.yellow,
      green: colors.green,
      blue: colors.blue,
      indigo: colors.indigo,
      purple: colors.purple,
      pink: colors.pink,
      // Add extended colors that content types use
      slate: colors.slate,
      zinc: colors.zinc,
      neutral: colors.neutral,
      stone: colors.stone,
      orange: colors.orange,
      amber: colors.amber,
      lime: colors.lime,
      emerald: colors.emerald,
      teal: colors.teal,
      cyan: colors.cyan,
      sky: colors.sky,
      violet: colors.violet,
      fuchsia: colors.fuchsia,
      rose: colors.rose,
      brown: {
        50: '#fdf8f6',
        100: '#f2e8e5',
        200: '#eaddd7',
        300: '#e0cec7',
        400: '#d2bab0',
        500: '#bfa094',
        600: '#a18072',
        700: '#977669',
        800: '#846358',
        900: '#43302b',
      },
    },
    extend: {
      colors: {
        'notebook-blue': '#2196F3',
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/line-clamp'),
  ],
}
