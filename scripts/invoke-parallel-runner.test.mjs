// Exercita o runner Bash real com CLIs locais falsos, sem chamadas a provedores.
import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const script = path.join(path.dirname(fileURLToPath(import.meta.url)), "invoke-parallel-runner.sh");
const bash = process.platform === "win32" ? "C:/Program Files/Git/bin/bash.exe" : "bash";
const probe = spawnSync(bash, ["-c", "command -v jq && command -v timeout"], { encoding: "utf8" });
const indisponivel = process.platform === "win32" && probe.status !== 0
  ? `Bash/jq/timeout indisponiveis: ${probe.error?.message || probe.stderr.trim() || `exit ${probe.status}`}` : false;

for (const json of [true, false]) {
  for (const [cenario, codigos] of [
    ["sucesso inicial em zero", [0, 0]],
    ["falha inicial em zero", [7, 9]],
    ["resultados mistos", [0, 7]],
    ["timeout", [124]],
  ]) {
    test(`Bash ${json ? "JSON" : "texto"}: ${cenario}`, { skip: indisponivel }, (t) => {
      const raiz = fs.mkdtempSync(path.join(os.tmpdir(), "sta-bash-"));
      t.after(() => fs.rmSync(raiz, { recursive: true, force: true }));
      const bin = path.join(raiz, "bin");
      fs.mkdirSync(bin);
      fs.writeFileSync(path.join(bin, "claude"), '#!/usr/bin/env bash\nexit "$2"\n', { mode: 0o755 });
      const manifest = path.join(raiz, "manifest.json");
      fs.writeFileSync(manifest, JSON.stringify(codigos.map((codigo, i) => ({
        id: `tarefa_${i}`, engine: "claude", prompt: String(codigo), working_directory: raiz,
      }))));
      const r = spawnSync(bash, [script, "-m", manifest, ...(json ? ["--json"] : [])], {
        env: { ...process.env, PATH: `${bin}${path.delimiter}${process.env.PATH}` },
        encoding: "utf8", timeout: 30000,
      });
      const falhas = codigos.filter((c) => c !== 0).length;
      assert.equal(r.status, falhas ? 1 : 0, r.stdout + r.stderr);
      if (json) {
        const resultado = JSON.parse(r.stdout);
        assert.equal(resultado.summary.success, codigos.length - falhas);
        assert.equal(resultado.summary.failed, falhas);
        assert.deepEqual(resultado.tasks.map((task) => task.exit_code), codigos);
        assert.deepEqual(resultado.tasks.map((task) => task.status), codigos.map((c) =>
          c === 0 ? "success" : c === 124 ? "timeout" : "failed"));
      } else {
        assert.match(r.stdout, new RegExp(`Sucessos: ${codigos.length - falhas} \\| Falhas: ${falhas}`));
        codigos.forEach((c, i) => assert.ok(r.stdout.includes(
          `[${c === 0 ? "success" : c === 124 ? "timeout" : "failed"}] ID: tarefa_${i}`), r.stdout));
      }
    });
  }
}
