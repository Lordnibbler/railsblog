const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
    content: [
        './app/**/*.html.erb',
        './app/**/*.html.slim',
        './app/**/*.slim',
        './app/controllers/**/*.rb',
        './app/helpers/**/*.rb',
        './app/javascript/**/*.js',
        './app/models/**/*.rb',
        './app/services/**/*.rb',
        './config/initializers/client_side_validations.rb',
    ],
    darkMode: "media",
    theme: {
        screens: {
            xs: "375px",
            ...defaultTheme.screens
        },
        extend: {
            backgroundImage: {
                'work-bg-light': "url('assets/experience-figure.svg')",
                'work-bg-dark': "url('assets/experience-figure-dark.svg')",
            },
            fontFamily: {
                header: ['Raleway', "sans-serif"],
                body: ['Open Sans', "sans-serif"]
            },
            colors: {
                transparent: "transparent",
                primary: "#5540af",
                secondary: "#252426",
                white: '#fafafa',
                black: "#000000",
                yellow: "#f9e71c",
                lila: "#e6e5ec",
                "grey-10": "#6c6b6d",
                "grey-20": "#7c7c7c",
                "grey-30": "#919091",
                "grey-40": "#929293",
                "grey-50": "#f4f3f8",
                "grey-60": "#edebf6",
                "grey-70": "#d8d8d8",

                // dark scheme defined at: https://www.color-hex.com/color/5540af
                "primary-10": "#080611", // closer to black
                "primary-20": "#110c23",
                "primary-30": "#191334",
                "primary-40": "#221946",
                "primary-50": "#2a2057",
                "primary-60": "#332669",
                "primary-70": "#3b2c7a",
                "primary-80": "#44338c",
                "primary-90": "#4c399d", // closer to primary
                "primary-100": "#5540af",
                "primary-200": "#6653b7",
                "primary-300": "#7666bf",
                "primary-400": "#8879c7",
                "primary-500": "#998ccf",
                "primary-600": "#aa9fd7",
                "primary-700": "#bbb2df",
                "primary-800": "#ccc5e7",
                "primary-900": "#ddd8ef",
                "primary-1000": "#eeebf7", // closer to white
                "hero-gradient-from": "rgba(85, 64, 174, 0.95)",       // primary
                "hero-gradient-to": "rgba(65, 47, 144, 0.70)",         // #412f90
                "hero-gradient-dark-from": "rgba(42, 32, 87, 0.95)",   // #080611
                "hero-gradient-dark-to": "rgba(42, 32, 87, 0.70)",     // #2a2057
                "cta-gradient-to": "rgba(65, 47, 144, 0.85)",
                "blog-gradient-from": "#8f9098",
                "blog-gradient-to": "#222222"
            },
            container: {
                center: true,
                padding: "1rem"
            },
            shadows: {
                default: '0 2px 18px rgba(0, 0, 0, 0.06)',
                md: '0 -3px 36px rgba(0, 0, 0, 0.12)',
            },
            spacing: {
                "13": '3.25rem',
                "15": '3.75rem',
                "17": '4.25rem',
                "18": '4.5rem',
                "19": '4.75rem',
                "42": '10.5rem',
                "76": "19rem",
                "84": "21rem",
                "88": "22rem",
                "92": "23rem",
                "100": "25rem",
                "104": "26rem",
                "108": "27rem",
                "112": "28rem",
                "116": "29rem",
                "120": "30rem",
                "124": "31rem",
                "128": "32rem",
                "132": "33rem",
                "136": "34rem",
                "140": "35rem",
                "144": "36rem",
                "148": "37rem",
                "152": "38rem",
                "156": "39rem",
                "160": "40rem",
                "164": "41rem",
                "168": "42rem",
                "172": "43rem",
                "176": "44rem",
                "180": "45rem",
                "184": "46rem",
                "188": "47rem",
                "190": "48rem",
                "194": "49rem",
                "200": "50rem",
                "204": "51rem"
            },
            zIndex: {
                "-1": "-1",
            },
            inset: {
                '2/5': '40%'
            },
            keyframes: {
                wiggle: {
                    '0%, 100%': {
                        transform: 'rotate(-3deg)'
                    },
                    '50%': {
                        transform: 'rotate(3deg)'
                    },
                },
                hideTop: {
                    from: { top: '0px' },
                    to: { top: '-100px' }
                },
                showTop: {
                    from: { top: '-100px' },
                    to: { top: '0px' }
                }
            },
            animation: {
                hideTop: 'hideTop 0.5s ease-in-out forwards',
                showTop: 'showTop 0.5s ease-in-out forwards'
            }
        }
    },
    variants: {
        extend: {
            display: ['responsive', 'group-hover'],
        }
    },
    plugins: [
        require("@tailwindcss/typography"),
        require("@tailwindcss/forms"),
        require("@tailwindcss/aspect-ratio"),
    ]
}