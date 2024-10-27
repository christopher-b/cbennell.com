const fs = require("fs");

const createTouchFilePlugin = (filePaths) => ({
  name: "touch-file",
  setup(build) {
    build.onStart(() => {
      if (!Array.isArray(filePaths) || filePaths.length === 0) {
        console.warn("No file paths provided to touch.");
        return;
      }

      const time = new Date();

      filePaths.forEach((filePath) => {
        try {
          fs.utimesSync(filePath, time, time);
        } catch (err) {
          fs.closeSync(fs.openSync(filePath, "w"));
        }
        console.log(`Touched file at ${filePath}`);
      });
    });
  }
});

module.exports = createTouchFilePlugin;
