const path = require('path');
const sassPlugin = require('esbuild-sass-plugin');

require("esbuild").build({
  entryPoints: ["application.js", "packs/contact-me.js"],
  bundle: true,
  outdir: path.join(process.cwd(), "app/assets/builds"),
  absWorkingDir: path.join(process.cwd(), "app/javascript"),
  watch: true,

  // custom plugins will be inserted in this array
  plugins: [sassPlugin.sassPlugin()],
}).catch(() => process.exit(1));
