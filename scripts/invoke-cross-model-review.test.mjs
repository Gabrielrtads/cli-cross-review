// Testa o invoke-cross-model-review.ps1 com CLIs falsos que registram chamadas e modelos.
import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync, spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const SCRIPT = path.join(path.dirname(fileURLToPath(import.meta.url)), "invoke-cross-model-review.ps1");
const onde = (exe) => path.dirname(execFileSync("where.exe", [exe], { encoding: "utf8" }).split(/\r?\n/)[0]);
const PATH_BASE = [onde("git"), onde("pwsh"), path.join(process.env.SystemRoot, "System32")];

function ambiente() {
  const raiz = fs.mkdtempSync(path.join(os.tmpdir(), "cross-review-"));
  const falsos = path.join(raiz, "bin");
  fs.mkdirSync(falsos);

  for (const nome of ["claude", "codex", "agy"]) {
    fs.writeFileSync(
      path.join(falsos, `${nome}.cmd`),
      [
        "@echo off",
        `>>"%FAKE_LOG%" echo ${nome} %*`,
        "echo {}",
        "exit /b 0",
        "",
      ].join("\r\n")
    );
  }

  const log = path.join(raiz, "chamadas.log");
  const dir = path.join(raiz, "repo");
  execFileSync("git", ["init", "-q", "-b", "main", dir]);
  execFileSync("git", ["-C", dir, "config", "user.email", "t@t"]);
  execFileSync("git", ["-C", dir, "config", "user.name", "t"]);
  fs.writeFileSync(path.join(dir, ".gitignore"), ".worktrees/\n");
  execFileSync("git", ["-C", dir, "add", "."]);
  execFileSync("git", ["-C", dir, "commit", "-qm", "base"]);

  const rodar = (engine, prompt, extra = []) => {
    const env = { ...process.env, PATH: [falsos, ...PATH_BASE].join(";"), FAKE_LOG: log };
    const r = spawnSync(
      "pwsh",
      [
        "-NoProfile",
        "-NonInteractive",
        "-File",
        SCRIPT,
        "-Engine",
        engine,
        "-Prompt",
        prompt,
        "-WorkingDirectory",
        dir,
        "-Json",
        ...extra,
      ],
      { env, encoding: "utf8" }
    );
    const chamadas = fs.existsSync(log) ? fs.readFileSync(log, "utf8") : "";
    fs.rmSync(log, { force: true });
    return { codigo: r.status, saida: r.stdout + r.stderr, chamadas };
  };

  return { dir, rodar, falsos, log };
}

test("revisao cruzada com claude dispara modelos balanceados (medium padrao) com sonnet espelhado", () => {
  const a = ambiente();
  const r = a.rodar("claude", "Auditoria de rotas de webhook");
  assert.equal(r.codigo, 0, r.saida);
  // Deve conter 2 chamadas com sonnet-5 (Builder + Red Team espelhado) e 1 com haiku-4.5
  const chamadasSonnet = (r.chamadas.match(/--model sonnet-5/g) || []).length;
  assert.equal(chamadasSonnet, 2, "Deveria ter 2 chamadas com sonnet-5 espelhado");
  assert.match(r.chamadas, /--model haiku-4\.5/);
  assert.match(r.chamadas, /--permission-mode plan/);
  assert.doesNotMatch(r.chamadas, /acceptEdits/);
});

test("revisao cruzada com claude e flag inline --high dispara opus-5 no red team", () => {
  const a = ambiente();
  const r = a.rodar("claude", "Auditoria de seguranca critica --high");
  assert.equal(r.codigo, 0, r.saida);
  assert.match(r.chamadas, /--model sonnet-5/);
  assert.match(r.chamadas, /--model opus-5/);
  assert.match(r.chamadas, /--model haiku-4\.5/);
});

test("revisao cruzada com claude e -Effort low dispara haiku-4.5", () => {
  const a = ambiente();
  const r = a.rodar("claude", "Auditoria simples", ["-Effort", "low"]);
  assert.equal(r.codigo, 0, r.saida);
  assert.match(r.chamadas, /--model haiku-4\.5/);
  assert.doesNotMatch(r.chamadas, /--model opus-5/);
});

test("revisao cruzada com codex dispara gpt-6.1-sol espelhado por padrao e gpt-6-astra no high", () => {
  const a = ambiente();
  // Padrao (medium para tarefa sem risco critico)
  const rMed = a.rodar("codex", "Refatoracao de algoritmo de busca em grafo");
  assert.equal(rMed.codigo, 0, rMed.saida);
  const chamadasSol = (rMed.chamadas.match(/--model gpt-6\.1-sol/g) || []).length;
  assert.equal(chamadasSol, 2, "Deveria ter 2 chamadas com gpt-6.1-sol espelhado no medium");
  assert.match(rMed.chamadas, /--model gpt-6-luna/);

  // High
  const rHigh = a.rodar("codex", "Verificacao critica --high");
  assert.equal(rHigh.codigo, 0, rHigh.saida);
  assert.match(rHigh.chamadas, /--model gpt-6-astra/);
});

test("revisao cruzada com agy dispara flash no low e opus-5-5 no high", () => {
  const a = ambiente();
  // Low
  const rLow = a.rodar("agy", "Teste rapido --low");
  assert.equal(rLow.codigo, 0, rLow.saida);
  const chamadasFlash = (rLow.chamadas.match(/--model gemini-3\.8-flash-low/g) || []).length;
  assert.equal(chamadasFlash, 3, "Deveria ter 3 chamadas flash-low no modo low");

  // High
  const rHigh = a.rodar("agy", "Teste de arquitetura pesada --high");
  assert.equal(rHigh.codigo, 0, rHigh.saida);
  assert.match(rHigh.chamadas, /--model gemini-4-argon-high/);
  assert.match(rHigh.chamadas, /--model claude-opus-5-5-high/);
});

test("modo auto faz triagem inteligente: seleciona high para supabase e low para css", () => {
  const a = ambiente();
  // Triagem high
  const rHigh = a.rodar("claude", "Migracao critica no supabase com token e auth");
  assert.equal(rHigh.codigo, 0, rHigh.saida);
  assert.match(rHigh.chamadas, /--model opus-5/);

  // Triagem low
  const rLow = a.rodar("claude", "Ajustar css e tailwind de cores do layout");
  assert.equal(rLow.codigo, 0, rLow.saida);
  assert.match(rLow.chamadas, /--model haiku-4\.5/);
  assert.doesNotMatch(rLow.chamadas, /--model opus-5/);
});

test("tribunal v2: executa 2 rodadas causais (Defesa + Acusacao na R1, Magistrado na R2)", () => {
  const a = ambiente();
  const r = a.rodar("claude", "Auditoria de pricing e monetizacao saas");
  assert.equal(r.codigo, 0, r.saida);
  assert.match(r.chamadas, /ADVOGADO DE DEFESA/);
  assert.match(r.chamadas, /PROMOTOR DE JUST/);
  assert.match(r.chamadas, /MAGISTRADO SUPREMO/);
});

test("tribunal alias: invoke-tribunal.ps1 despacha com sucesso", () => {
  const a = ambiente();
  const tribScript = path.join(path.dirname(SCRIPT), "invoke-tribunal.ps1");
  const env = { ...process.env, PATH: [a.falsos, ...PATH_BASE].join(";"), FAKE_LOG: a.log };
  const r = spawnSync(
    "pwsh",
    ["-NoProfile", "-NonInteractive", "-File", tribScript, "-Engine", "claude", "-Prompt", "Roteiro de video e copy viral", "-WorkingDirectory", a.dir, "-Json"],
    { env, encoding: "utf8" }
  );
  assert.equal(r.status, 0, r.stdout + r.stderr);
});
