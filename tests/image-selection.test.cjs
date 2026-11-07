const assert = require('node:assert/strict');
const { readFileSync, mkdtempSync, writeFileSync, rmSync } = require('node:fs');
const { execFileSync, spawnSync } = require('node:child_process');
const { tmpdir } = require('node:os');
const { join } = require('node:path');
const { test } = require('node:test');

const workflow = readFileSync('.github/workflows/deploy.yaml', 'utf8');
const select = workflow.match(/- name: Select image[\s\S]*?run: \|\n([\s\S]*?)(?=\n      - uses:)/)[1]
  .split('\n').map(line => line.slice(10)).join('\n');

test('both build modes and latest publication use the Environment image path', () => {
  const folder = mkdtempSync(join(tmpdir(), 'minecraft-image-'));
  try {
    for (const imageName of ['minecraft/svc-minecraft', 'alternate/renamed-game']) {
      for (const build of ['true', 'false']) {
        const output = join(folder, 'env');
        writeFileSync(output, '');
        execFileSync('bash', ['-euc', select], { env: {
          ...process.env, BUILD_IMAGE: build, REGISTRY: 'registry.example:5000',
          IMAGE_NAME: imageName, GITHUB_SHA: 'synthetic-sha', GITHUB_ENV: output,
        } });
        assert.equal(readFileSync(output, 'utf8'),
          `IMAGE=registry.example:5000/${imageName}:${build === 'true' ? 'synthetic-sha' : 'latest'}\nIMAGE_LATEST=registry.example:5000/${imageName}:latest\n`);
      }
    }
    assert.match(workflow, /IMAGE_NAME: \$\{\{ vars.DOCKER_IMAGE }}/);
    assert.match(workflow, /\$\{\{ env.IMAGE_LATEST }}/);
    assert.match(workflow, /default: '0'/);
    assert.doesNotMatch(workflow, /library\/svc-minecraft/);
  } finally { rmSync(folder, { recursive: true, force: true }); }
});

test('invalid registry or image paths fail before exporting any image', () => {
  const folder = mkdtempSync(join(tmpdir(), 'minecraft-image-invalid-'));
  try {
    for (const invalid of [
      { REGISTRY: '' }, { REGISTRY: 'https://registry.example' },
      { IMAGE_NAME: '' }, { IMAGE_NAME: 'svc-minecraft' },
      { IMAGE_NAME: 'project/image:latest' }, { IMAGE_NAME: '../project/image' },
      { IMAGE_NAME: 'project/image\nOTHER=value' },
    ]) {
      const output = join(folder, 'env');
      writeFileSync(output, '');
      const result = spawnSync('bash', ['-euc', select], { env: {
        ...process.env, BUILD_IMAGE: 'false', REGISTRY: 'registry.example',
        IMAGE_NAME: 'minecraft/svc-minecraft', GITHUB_SHA: 'synthetic-sha', GITHUB_ENV: output, ...invalid,
      } });
      assert.notEqual(result.status, 0);
      assert.equal(readFileSync(output, 'utf8'), '');
    }
  } finally { rmSync(folder, { recursive: true, force: true }); }
});
