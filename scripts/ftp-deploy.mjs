// Upload manual do tema para o FTP de produção, para teste rápido sem
// passar pelo fluxo git (PR -> merge master -> ftp-deploy.yml).
//
// Espera FTP_HOST / FTP_USERNAME / FTP_PASSWORD no ambiente (ver .env.example).
// Rodar com: node --env-file=.env scripts/ftp-deploy.mjs

import { Client } from "basic-ftp";
import path from "node:path";

const DIRS = ["config", "layouts", "snipplets", "static", "templates"];

const { FTP_HOST, FTP_USERNAME, FTP_PASSWORD } = process.env;

if (!FTP_HOST || !FTP_USERNAME || !FTP_PASSWORD) {
  console.error(
    "Faltam variáveis FTP_HOST / FTP_USERNAME / FTP_PASSWORD.\n" +
      "Copie .env.example para .env e preencha, depois rode:\n" +
      "  node --env-file=.env scripts/ftp-deploy.mjs"
  );
  process.exit(1);
}

const client = new Client();
client.ftp.verbose = process.argv.includes("--verbose");

try {
  await client.access({
    host: FTP_HOST,
    user: FTP_USERNAME,
    password: FTP_PASSWORD,
    secure: true,
  });

  for (const dir of DIRS) {
    console.log(`Enviando ${dir}/ ...`);
    await client.uploadFromDir(path.resolve(dir), `/${dir}`);
  }

  console.log("Deploy FTP concluído.");
} catch (err) {
  console.error("Erro no deploy FTP:", err.message ?? err);
  process.exitCode = 1;
} finally {
  client.close();
}
