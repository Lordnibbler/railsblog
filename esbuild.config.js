const path = require('path');
const sassPlugin = require('esbuild-sass-plugin');
const postCssPlugin = require("@deanc/esbuild-plugin-postcss");

const watch = process.argv.includes("--watch") && {
  onRebuild(error) {
    if (error) console.error("[watch] build failed", error);
    else console.log("[watch] build finished");
  },
};

require("esbuild").build({
  entryPoints: [
    "app/javascript/application.js",
    "app/javascript/packs/contact-me.js",
    "app/javascript/packs/blog.js",
    "app/javascript/packs/photography.js"],
  bundle: true,
  outdir: path.join(process.cwd(), "app/assets/builds"),
  absWorkingDir: path.join(process.cwd()),
  watch: watch,
  loader: {
    ".gif": "file",
    ".jpg": "file",
    ".jpeg": "file",
    ".png": "file",
    ".svg": "file",
  },
  resolveExtensions: [".tsx", ".ts", ".jsx", ".js", ".css", ".json"],

  // custom plugins will be inserted in this array
  plugins: [
    sassPlugin.sassPlugin(),
    postCssPlugin({
      plugins: [
        require('postcss-import'),
        require('autoprefixer'),
        require("tailwindcss"),
        require('postcss-flexbugs-fixes'),
        require('postcss-preset-env')({
          autoprefixer: {
            flexbox: 'no-2009'
          },
          stage: 3
        }),
      ],
    }),
  ],
})
.then(() => console.log("⚡ esbuild done"))
.catch(() => process.exit(1));
