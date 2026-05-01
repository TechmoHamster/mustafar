#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const requiredFiles = [
  'index.html',
  'mustafar_playbook.html',
  'CODEX_README.md',
  'package.json',
  'config/Brewfile',
  'config/docker-compose.yml',
  'config/prometheus.yml',
  'scripts/ssd_phase0_preflight.sh',
  'scripts/ssd_phase1_backup.sh',
  'scripts/ssd_phase10_validate.sh'
];

let failed = false;

function fail(message) {
  failed = true;
  console.error(`✗ ${message}`);
}

function pass(message) {
  console.log(`✓ ${message}`);
}

for (const file of requiredFiles) {
  const fullPath = path.join(root, file);
  if (!fs.existsSync(fullPath)) fail(`Missing required file: ${file}`);
  else pass(`Found ${file}`);
}

const htmlPath = path.join(root, 'mustafar_playbook.html');
if (fs.existsSync(htmlPath)) {
  const html = fs.readFileSync(htmlPath, 'utf8');
  const requiredSnippets = [
    'Server Conversion',
    'SSD & OS Upgrade',
    'scripts/ssd_phase0_preflight.sh',
    'scripts/ssd_phase1_backup.sh',
    'scripts/ssd_phase10_validate.sh',
    'localStorage',
    'switchTab'
  ];

  for (const snippet of requiredSnippets) {
    if (!html.includes(snippet)) fail(`mustafar_playbook.html missing snippet: ${snippet}`);
    else pass(`HTML includes ${snippet}`);
  }
}

const composePath = path.join(root, 'config/docker-compose.yml');
if (fs.existsSync(composePath)) {
  const compose = fs.readFileSync(composePath, 'utf8');
  if (compose.includes('./prometheus.yml') && !fs.existsSync(path.join(root, 'config/prometheus.yml'))) {
    fail('config/docker-compose.yml references ./prometheus.yml, but config/prometheus.yml is missing');
  } else {
    pass('Docker compose Prometheus config reference is satisfied');
  }
}

if (failed) {
  console.error('\nValidation failed. Fix the items above.');
  process.exit(1);
}

console.log('\nMustafar static app validation passed.');
