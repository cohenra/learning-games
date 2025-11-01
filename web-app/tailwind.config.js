/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#fef3e2',
          100: '#fde7c5',
          200: '#fbcf8b',
          300: '#f9b751',
          400: '#f7a028',
          500: '#f58800',
          600: '#dd7800',
          700: '#b86200',
          800: '#934d00',
          900: '#753d00',
        },
        secondary: {
          50: '#e6f7ff',
          100: '#bae7ff',
          200: '#8dd8ff',
          300: '#61c9ff',
          400: '#34b9ff',
          500: '#00a8ff',
          600: '#0095e6',
          700: '#007bbf',
          800: '#006299',
          900: '#004973',
        },
      },
      fontFamily: {
        'fredoka': ['Fredoka One', 'cursive'],
        'alef': ['Alef', 'sans-serif'],
      },
      fontSize: {
        'xxl': '2rem',
        '3xl': '2.5rem',
        '4xl': '3rem',
        '5xl': '4rem',
      },
    },
  },
  plugins: [],
}
