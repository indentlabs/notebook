const colors = require('tailwindcss/colors');

module.exports = {
  purge: [
    'app/views/**/*.html.erb'
  ],
  safelist: [
    // Toggle switch classes
    'toggle-switch',
    'toggle-dot',
    'bg-notebook-blue',
    'translate-x-5',
    'translate-x-0',
    // Icon rotation animation
    'rotate-90',
    'group-hover:rotate-90',
    'transition-transform',
    'duration-200',
    // Ensure pseudo-element classes aren't purged if used elsewhere
    { pattern: /^after:/ },
    { pattern: /^peer/ },
  ],
  content: [],
  theme: {
    extend: {
      colors: {
        'notebook-blue': '#2196F3',
        slate: colors.slate,
        gray: colors.gray,
        zinc: colors.zinc,
        neutral: colors.neutral,
        stone: colors.stone,
        red: colors.red,
        orange: colors.orange,
        amber: colors.amber,
        yellow: colors.yellow,
        lime: colors.lime,
        green: colors.green,
        emerald: colors.emerald,
        teal: colors.teal,
        cyan: colors.cyan,
        sky: colors.sky,
        blue: colors.blue,
        indigo: colors.indigo,
        violet: colors.violet,
        purple: colors.purple,
        fuchsia: colors.fuchsia,
        pink: colors.pink,
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
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/line-clamp'),
  ],
}
