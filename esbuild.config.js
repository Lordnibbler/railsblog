const path = require('path');
const sassPlugin = require('esbuild-sass-plugin');
const autoprefixer = require("autoprefixer");
const postCssPlugin = require("@deanc/esbuild-plugin-postcss");

const watch = process.argv.includes("--watch") && {
  onRebuild(error) {
    if (error) console.error("[watch] build failed", error);
    else console.log("[watch] build finished");
  },
};

require("esbuild").build({
  entryPoints: ["application.js", "packs/contact-me.js"],
  bundle: true,
  outdir: path.join(process.cwd(), "app/assets/builds"),
  absWorkingDir: path.join(process.cwd(), "app/javascript"),
  watch: watch,

  // custom plugins will be inserted in this array
  plugins: [
    sassPlugin.sassPlugin(),
    postCssPlugin({
      plugins: [autoprefixer, require('tailwindcss')],
    }),
  ],
}).catch(() => process.exit(1));
