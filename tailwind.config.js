/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        forest: '#1a5e3a',
        leaf: '#2d8a5e',
        mint: '#e8f5ee',
        cream: '#f9fcfa',
        gold: '#c8a951'
      },
      fontFamily: {
        display: ['"Playfair Display"', 'Georgia', 'serif'],
        body: ['"DM Sans"', 'sans-serif']
      },
      keyframes: {
        fadeUp: {
          from: { opacity: 0, transform: 'translateY(30px)' },
          to: { opacity: 1, transform: 'translateY(0)' }
        }
      },
      animation: {
        'fade-up': 'fadeUp 0.8s ease forwards',
        'fade-up-2': 'fadeUp 0.8s ease 0.15s forwards',
        'fade-up-3': 'fadeUp 0.8s ease 0.3s forwards',
        'fade-up-4': 'fadeUp 0.8s ease 0.45s forwards'
      }
    },
  },
  plugins: [],
}
