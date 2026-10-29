// Testa o invoke-cross-model-review.ps1 com CLIs falsos que registram chamadas e modelos.
import { test, after } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync, spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const SCRIPT = path.join(path.dirname(fileURLToPath(import.meta.url)), "invoke-cross-model-review.ps1");
const onde = (exe) => path.dirname(execFileSync("where.exe", [exe], { encoding: "utf8" }).split(/\r?\n/)[0]);
const PATH_BASE = [onde("git"), onde("pwsh"), path.join(process.env.SystemRoot, "System32")];
const temporarios = [];
after(() => temporarios.forEach((raiz) => fs.rmSync(raiz, { recursive: true, force: true })));

function ambiente() {
  const raiz = fs.mkdtempSync(path.join(os.tmpdir(), "cross-review-"));
  temporarios.push(raiz);
  const falsos = path.join(raiz, "bin");
  fs.mkdirSync(falsos);

  for (const nome of ["claude", "codex", "agy"]) {
    fs.writeFileSync(
      path.join(falsos, `${nome}.ps1`),
      [
        "[Console]::InputEncoding = [Text.UTF8Encoding]::new($false)",
        "if ($env:FAKE_EXIT_STDIN) { exit 0 }",
        "if ($env:FAKE_BLOCK_STDIN) { Start-Sleep -Seconds 30; exit 0 }",
        "if ($env:FAKE_NOISY) { [Console]::Out.Write(' ' * 131072) }",
        "$promptText = [Console]::In.ReadToEnd()",
        `$registro = '${nome} ' + ($args -join ' ') + ' ' + $promptText`,
        "[IO.File]::WriteAllText((Join-Path $env:FAKE_LOG ([guid]::NewGuid().ToString() + '.json')), (@{ arguments = @($args); prompt = $promptText; registro = $registro } | ConvertTo-Json -Compress))",
        "Write-Output '{}'",
        "exit 0",
        "",
      ].join("\r\n")
    );
  }

  const log = path.join(raiz, "chamadas");
  fs.mkdirSync(log);
  const dir = path.join(raiz, "repo");
  fs.mkdirSync(dir); // Roteamento e modelos tambem devem funcionar fora de um repositorio Git.

  const rodar = (engine, prompt, extra = []) => {
    const env = { ...process.env, SWARM_DEPTH: "0", PATH: [falsos, ...PATH_BASE].join(";"), FAKE_LOG: log };
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
    const chamadas = fs.readdirSync(log).map((f) => {
      const arquivo = path.join(log, f);
      const registro = JSON.parse(fs.readFileSync(arquivo, "utf8"));
      fs.rmSync(arquivo);
      return registro.registro;
    }).join("\n");
    return { codigo: r.status, saida: r.stdout + r.stderr, chamadas };
  };

  return { raiz, dir, rodar, falsos, log };
}

function rodarRunner(a, tasks, extraEnv = {}) {
  const manifest = path.join(a.raiz, "manifest.json");
  fs.writeFileSync(manifest, JSON.stringify(tasks));
  return spawnSync("pwsh", ["-NoProfile", "-NonInteractive", "-File",
    path.join(path.dirname(SCRIPT), "invoke-parallel-runner.ps1"),
    "-ManifestPath", manifest, "-WorkingDirectory", a.dir, "-Json"], {
    env: { ...process.env, SWARM_DEPTH: "0", PATH: [a.falsos, ...PATH_BASE].join(";"), FAKE_LOG: a.log, ...extraEnv },
    encoding: "utf8", timeout: 10000,
  });
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
  const env = { ...process.env, SWARM_DEPTH: "0", PATH: [a.falsos, ...PATH_BASE].join(";"), FAKE_LOG: a.log };
  const r = spawnSync(
    "pwsh",
    ["-NoProfile", "-NonInteractive", "-File", tribScript, "-Engine", "claude", "-Prompt", "Roteiro de video e copy viral", "-WorkingDirectory", a.dir, "-Json"],
    { env, encoding: "utf8" }
  );
  assert.equal(r.status, 0, r.stdout + r.stderr);
});

test("flag --fogo no meio de frase com espacos reais seleciona high e sai do caso", (t) => {
  const a = ambiente();
  t.after(() => fs.rmSync(a.raiz, { recursive: true, force: true }));
  const r = a.rodar("claude", "Analise o algoritmo --fogo antes de concluir");
  assert.equal(r.codigo, 0, r.saida);
  assert.match(r.chamadas, /--model opus-5/);
  assert.doesNotMatch(r.chamadas, /--fogo/);
});

for (const engine of ["claude", "agy", "codex"]) {
  test(`runner ${engine}: prompt hostil chega inteiro por stdin, fora de argv`, (t) => {
    const a = ambiente();
    t.after(() => fs.rmSync(a.raiz, { recursive: true, force: true }));
    const marker = path.join(a.dir, "injetado.txt");
    const prompt = `Revisao ação \" & echo INJETADO > \"${marker}\" & \"\n%PATH% !VAR! | < > ^ \\ fim`;
    const r = rodarRunner(a, [{ id: "teste", engine, prompt }]);
    assert.equal(r.status, 0, r.stdout + r.stderr);
    const registros = fs.readdirSync(a.log).map((f) => JSON.parse(fs.readFileSync(path.join(a.log, f), "utf8")));
    assert.equal(registros.length, 1);
    const recebido = engine === "codex"
      ? `[MODO LEITURA / PLANO - APENAS ANALISE, NAO EDITE ARQUIVOS]\n${prompt}` : prompt;
    assert.equal(registros[0].prompt, recebido);
    assert.ok(registros[0].arguments.every((arg) => !arg.includes("INJETADO")));
    assert.equal(fs.existsSync(marker), false);
  });

  test(`runner ${engine}: prompt grande com saida antecipada nao bloqueia stdin`, (t) => {
    const a = ambiente();
    t.after(() => fs.rmSync(a.raiz, { recursive: true, force: true }));
    const prompt = "diff com acao e aspas \" & \n".repeat(10000);
    const r = rodarRunner(a, [{ id: "grande", engine, mode: "execute", prompt }], { FAKE_NOISY: "1" });
    assert.equal(r.status, 0, r.error?.message || r.stdout + r.stderr);
    const arquivos = fs.readdirSync(a.log);
    assert.equal(arquivos.length, 1);
    assert.equal(JSON.parse(fs.readFileSync(path.join(a.log, arquivos[0]), "utf8")).prompt, prompt);
  });

  test(`runner ${engine}: timeout continua ativo quando CLI nao le stdin`, (t) => {
    const a = ambiente();
    t.after(() => fs.rmSync(a.raiz, { recursive: true, force: true }));
    const r = rodarRunner(a, [{ id: "bloqueado", engine, prompt: "x".repeat(1048576), timeout_seconds: 1 }], {
      FAKE_BLOCK_STDIN: "1",
    });
    assert.equal(r.status, 1, r.error?.message || r.stdout + r.stderr);
    const resultado = JSON.parse(r.stdout);
    assert.equal(resultado.summary.timeout, 1);
    assert.equal(resultado.tasks[0].status, "timeout");
    assert.equal(resultado.tasks[0].exit_code, 124);
  });

  test(`runner ${engine}: encerrar sem receber prompt nao pode reportar sucesso`, (t) => {
    const a = ambiente();
    t.after(() => fs.rmSync(a.raiz, { recursive: true, force: true }));
    const r = rodarRunner(a, [{ id: "interrompido", engine, prompt: "x".repeat(1048576) }], {
      FAKE_EXIT_STDIN: "1",
    });
    assert.equal(r.status, 1, r.error?.message || r.stdout + r.stderr);
    const resultado = JSON.parse(r.stdout);
    assert.equal(resultado.summary.failed, 1);
    assert.equal(resultado.tasks[0].status, "failed");
    assert.match(resultado.tasks[0].error_output, /prompt/);
  });

  for (const ext of ["CMD", "bAt"]) {
    test(`runner ${engine}: recusa shim .${ext} antes de executar`, (t) => {
      const a = ambiente();
      t.after(() => fs.rmSync(a.raiz, { recursive: true, force: true }));
      fs.rmSync(path.join(a.falsos, `${engine}.ps1`));
      const marker = path.join(a.dir, "shim-executado.txt");
      fs.writeFileSync(path.join(a.falsos, `${engine}.${ext}`), `@echo off\r\necho executado > "${marker}"\r\necho {}\r\n`);
      const r = a.rodar(engine, "Caso simples");
      assert.notEqual(r.codigo, 0, r.saida);
      assert.match(r.saida, /\.cmd\/\.bat.*recusad/i);
      assert.equal(fs.existsSync(marker), false);
    });
  }
}

test("runner prefere launcher seguro mesmo com .cmd anterior no PATH e modelo com metacaracteres", (t) => {
  const a = ambiente();
  t.after(() => fs.rmSync(a.raiz, { recursive: true, force: true }));
  const inseguro = path.join(a.raiz, "inseguro");
  fs.mkdirSync(inseguro);
  const marker = path.join(a.dir, "injetado.txt");
  fs.writeFileSync(path.join(inseguro, "claude.cmd"), `@echo off\r\necho executado > "${marker}"\r\necho {}\r\n`);
  const model = `modelo \" & echo INJETADO > \"${marker}\" & \"`;
  const r = rodarRunner(a, [{ id: "seguro", engine: "claude", prompt: "Caso comum", model }], {
    PATH: [inseguro, a.falsos, ...PATH_BASE].join(";"),
  });
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.equal(fs.existsSync(marker), false);
  const arquivos = fs.readdirSync(a.log);
  assert.equal(arquivos.length, 1);
  assert.ok(JSON.parse(fs.readFileSync(path.join(a.log, arquivos[0]), "utf8")).arguments.includes(model));
});
