const fs = require("fs");
const path = require("path");

const epoch = Date.now();
const newFileName = `gaius-v${epoch}.js`;

const regex = /gaius-v\d+\.js/g;

function updateFile(filePath) {
  if (!fs.existsSync(filePath)) {
    console.log("Arquivo não encontrado:", filePath);
    return;
  }

  const originalContent = fs.readFileSync(filePath, "utf8");

  const updatedContent = originalContent.replace(regex, newFileName);

  fs.writeFileSync(filePath, updatedContent);

  console.log("Atualizado:", filePath);
}

updateFile(path.join(__dirname, "esbuild.config.mjs"));
updateFile(path.join(__dirname, "layouts/layout.tpl"));

console.log("Nova versão:", newFileName);