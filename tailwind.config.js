/** @type {import('tailwindcss').Config} */
  module.exports = {
    content: [
      './src/**/*.{html,md,liquid,erb,serb,rb}',
      './frontend/javascript/**/*.js',
    ],
    theme: {
      container: {
        center: true,
        padding: '1rem',
      },
      fontFamily: {
        // https://github.com/system-fonts/modern-font-stacks
        geohumanist:  ['Avenir', 'Montserrat', 'Corbel', 'URW Gothic', 'source-sans-pro', 'sans-serif'],
        //systemui:     ['system-ui', 'sans-serif'],
        //transitional: ['Charter', 'Bitstream Charter', 'Sitka Text', 'Cambria', 'serif'],
        //oldstyle:     ['Iowan Old Style', 'Palatino Linotype', 'URW Palladio L', 'P052', 'serif'],
        //humanist:     ['Seravek', 'Gill Sans Nova', 'Ubuntu', 'Calibri', 'DejaVu Sans', 'source-sans-pro', 'sans-serif'],
        //classhuman:   ['Optima', 'Candara', 'Noto Sans', 'source-sans-pro', 'sans-serif'],
        //neogrote:     ['Inter', 'Roboto', 'Helvetica Neue', 'Arial Nova', 'Nimbus Sans', 'Arial', 'sans-serif'],
        //monoslab:     ['Nimbus Mono PS', 'Courier New', 'monospace'],
        //monocode:     ['ui-monospace', 'Cascadia Code', 'Source Code Pro', 'Menlo', 'Consolas', 'DejaVu Sans Mono', 'monospace'],
        //industrial:   ['Bahnschrift', 'DIN Alternate', 'Franklin Gothic Medium', 'Nimbus Sans Narrow', 'sans-serif-condensed', 'sans-serif'],
        //roundsans:    ['ui-rounded', 'Hiragino Maru Gothic ProN', 'Quicksand', 'Comfortaa', 'Manjari', 'Arial Rounded MT', 'Arial Rounded MT Bold', 'Calibri', 'source-sans-pro', 'sans-serif'],
        //slabserif:    ['Rockwell', 'Rockwell Nova', 'Roboto Slab', 'DejaVu Serif', 'Sitka Small', 'serif'],
        //antique:      ['Superclarendon', 'Bookman Old Style', 'URW Bookman', 'URW Bookman L', 'Georgia Pro', 'Georgia', 'serif'],
        //didone:       ['Didot', 'Bodoni MT', 'Noto Serif Display', 'URW Palladio L', 'P052', 'Sylfaen', 'serif'],
        //handwritten:  ['Segoe Print', 'Bradley Hand', 'Chilanka', 'TSCu_Comic', 'casual', 'cursive'],
      },
      extend: {
        borderRadius: {
          'xl': '1.5rem'
        },
        colors: {
          // https://uicolors.app/create #d83909
          'grenadier': {
            '50': '#fff6ed',
            '100': '#ffead4',
            '200': '#ffd2a8',
            '300': '#ffb271',
            '400': '#ff8638',
            '500': '#fe6411',
            '600': '#ef4907',
            '700': '#d83909',
            '800': '#9d2b0f',
            '900': '#7e2510',
            '950': '#440f06',
          },
        },
      },
    },
    plugins: [
      require('@tailwindcss/typography'),
    ],
  }

