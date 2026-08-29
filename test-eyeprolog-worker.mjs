#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const [engineRoot, outputDir, ...inputFiles] = process.argv.slice(2);
if (!engineRoot || !outputDir || inputFiles.length === 0) {
  console.error('usage: test-eyeprolog-worker.mjs ENGINE_ROOT OUTPUT_DIR INPUT...');
  process.exit(64);
}

const engine = await import(pathToFileURL(path.join(engineRoot, 'index.js')).href);
await fs.mkdir(outputDir, { recursive: true });

for (const inputFile of inputFiles) {
  const started = process.hrtime.bigint();
  let status = 0;
  let stdout = '';
  let stderr = '';
  try {
    const inputText = await fs.readFile(inputFile, 'utf8');
    let program = engine.Program.parseSources([
      {
        text: inputText,
        filename: path.basename(inputFile),
        baseDir: path.dirname(path.resolve(inputFile)),
      },
    ], {
      // Match normal EyeProlog CLI execution while reusing one Node/V8 process.
      sourceMetadata: false,
      isoStrict: false,
      autoload: true,
      autoloadGoals: [],
    });

    const solver = new engine.Solver(program, {
      registry: engine.createEyePrologRegistry(),
      ioOptions: {
        write: (text) => { stdout += String(text); },
        errorWrite: (text) => { stderr += String(text); },
      },
    });
    program = solver.program;

    if (engine.hasForwardRules(program)) {
      const result = engine.executeForwardRules(program, solver, {
        onAnswer: (line) => { stdout += line; },
        onFuse: (line) => { stdout += line; },
        onDiagnostic: (line) => { stderr += line; },
      });
      if (result.haltCode != null) status = result.haltCode;
    }
  } catch (error) {
    status = 1;
    stderr += `${error?.stack ?? error}\n`;
  }

  const elapsedMs = Number(process.hrtime.bigint() - started) / 1e6;
  const name = path.basename(inputFile);
  await fs.writeFile(path.join(outputDir, name), stdout);
  if (stderr) process.stderr.write(stderr);
  process.stdout.write(`${name}\t${elapsedMs.toFixed(1)}\t${status}\n`);
}
