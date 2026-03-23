/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      boxShadow: {
        panel: '0 24px 80px rgba(14, 23, 44, 0.18)',
      },
      colors: {
        ink: '#0f172a',
        mist: '#f8fafc',
        accent: '#f97316',
        ocean: '#0f766e',
      },
    },
  },
  plugins: [],
}
