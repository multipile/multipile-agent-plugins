#!/usr/bin/env node
// Builds every host-specific catalog file from the single source of truth:
//
//   marketplace.config.json      marketplace name, owner, and the list of plugins to publish
//   plugins/<name>/plugin.json   each plugin's portable Agent Plugins manifest
//
// Outputs (never edit these by hand):
//
//   .claude-plugin/marketplace.json          read by Claude Code
//   .agents/plugins/marketplace.json         read by Codex
//   plugins/<name>/.claude-plugin/plugin.json  Claude manifest; identity fields are copied
//                                              from plugin.json, Claude-only keys are kept
//
// Every plugin is first checked against the plugin and skill rules
// by validate-plugin.mjs; a plugin that fails stops the build.
//
// Usage:  node scripts/build-catalog.mjs          write the outputs
//         node scripts/build-catalog.mjs --check  exit 1 if any output is stale or invalid

import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { PLUGIN_NAME_RE, validatePluginDir } from "./validate-plugin.mjs";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const CONFIG_PATH = join(ROOT, "marketplace.config.json");
const IDENTITY_FIELDS = ["name", "version", "description", "author", "homepage", "repository", "license", "keywords"];
const DISPLAY_FIELDS = ["description", "author", "homepage", "repository", "license", "keywords"];

const checkOnly = process.argv.includes("--check");
const errors = [];
const warnings = [];
const fail = (msg) => errors.push(msg);
const rel = (p) => (p.startsWith(ROOT) ? p.slice(ROOT.length + 1) : p);
const stringify = (obj) => JSON.stringify(obj, null, 2) + "\n";

function readJson(path) {
  try {
    return JSON.parse(readFileSync(path, "utf8"));
  } catch (err) {
    fail(`${rel(path)}: ${err.message}`);
    return null;
  }
}

function pick(obj, keys) {
  const out = {};
  for (const key of keys) if (obj[key] !== undefined) out[key] = obj[key];
  return out;
}

// Put `first` keys in order at the front; keep every other key in its existing order.
function orderKeys(obj, first) {
  const out = {};
  for (const key of first) if (obj[key] !== undefined) out[key] = obj[key];
  for (const key of Object.keys(obj)) if (!(key in out)) out[key] = obj[key];
  return out;
}

function finish() {
  for (const w of warnings) console.warn(`warning: ${w}`);
  if (errors.length) {
    console.error(`build-catalog: ${errors.length} problem(s)`);
    for (const e of errors) console.error(`  - ${e}`);
    process.exit(1);
  }
}

const config = readJson(CONFIG_PATH);
if (!config) finish();

if (typeof config.name !== "string" || !PLUGIN_NAME_RE.test(config.name)) {
  fail(`marketplace.config.json: "name" must be lowercase kebab-case (got ${JSON.stringify(config.name)})`);
}
if (!config.owner?.name) fail('marketplace.config.json: "owner.name" is required');
if (!Array.isArray(config.plugins) || config.plugins.length === 0) {
  fail('marketplace.config.json: "plugins" must be a non-empty array');
}
const pluginRoot = config.pluginRoot ?? "./plugins";
if (!pluginRoot.startsWith("./") || pluginRoot.includes("..")) {
  fail('marketplace.config.json: "pluginRoot" must start with "./" and stay inside the repository');
}
const defaults = config.defaults ?? {};

const outputs = new Map(); // absolute path -> file content
const claudeEntries = [];
const codexEntries = [];
const seen = new Set();

for (const entry of config.plugins ?? []) {
  const dir = entry?.dir;
  if (typeof dir !== "string" || !dir || dir.includes("/") || dir.includes("\\") || dir.includes("..")) {
    fail(`marketplace.config.json: each plugin needs a "dir" that is a single directory name (got ${JSON.stringify(dir)})`);
    continue;
  }
  const pluginDir = join(ROOT, pluginRoot, dir);

  // The rules for the plugin package itself.
  const checked = validatePluginDir(pluginDir);
  errors.push(...checked.errors);
  warnings.push(...checked.warnings);
  const manifest = checked.manifest;
  if (!manifest || checked.errors.length) continue;

  // Marketplace rules on top of those.
  if (manifest.name !== dir) {
    fail(`${rel(pluginDir)}/plugin.json: "name" (${manifest.name}) must equal its directory name (${dir}); Claude Code keys installs by the entry name`);
  }
  if (seen.has(manifest.name)) fail(`${rel(pluginDir)}/plugin.json: duplicate plugin name ${manifest.name}`);
  seen.add(manifest.name);

  const openai = manifest.extensions?.["com.openai"] ?? {};
  const category = entry.category ?? defaults.category ?? openai.interface?.category;
  if (!category) fail(`${dir}: "category" is required; set it on the entry or in "defaults"`);
  const policy = { ...(defaults.policy ?? {}), ...(entry.policy ?? {}) };
  if (!policy.installation || !policy.authentication) {
    fail(`${dir}: "policy.installation" and "policy.authentication" are required; set them on the entry or in "defaults"`);
  }
  const displayName = entry.displayName ?? openai.interface?.displayName;
  const source = `${pluginRoot}/${dir}`;

  claudeEntries.push({
    name: manifest.name,
    source,
    ...(displayName ? { displayName } : {}),
    ...pick(manifest, DISPLAY_FIELDS),
    category,
    ...(entry.tags ? { tags: entry.tags } : {}),
    ...(entry.defaultEnabled !== undefined ? { defaultEnabled: entry.defaultEnabled } : {}),
    ...(entry.claude ?? {}),
  });

  codexEntries.push({
    name: manifest.name,
    source: { source: "local", path: source },
    policy,
    category,
    ...(entry.codex ?? {}),
  });

  // Claude manifest: identity from plugin.json wins; Claude-only keys (hooks, mcpServers, userConfig, ...) are preserved.
  const claudeManifestPath = join(pluginDir, ".claude-plugin", "plugin.json");
  const existing = existsSync(claudeManifestPath) ? readJson(claudeManifestPath) ?? {} : {};
  outputs.set(claudeManifestPath, stringify(orderKeys({ ...existing, ...pick(manifest, IDENTITY_FIELDS) }, IDENTITY_FIELDS)));
}

outputs.set(
  join(ROOT, ".claude-plugin", "marketplace.json"),
  stringify({
    name: config.name,
    ...(config.description ? { description: config.description } : {}),
    owner: config.owner,
    ...(config.version ? { version: config.version } : {}),
    plugins: claudeEntries,
    ...(config.claude ?? {}),
  }),
);

outputs.set(
  join(ROOT, ".agents", "plugins", "marketplace.json"),
  stringify({
    name: config.name,
    interface: { displayName: config.displayName ?? config.name },
    plugins: codexEntries,
    ...(config.codex ?? {}),
  }),
);

finish();

if (checkOnly) {
  const stale = [...outputs].filter(([path, content]) => !existsSync(path) || readFileSync(path, "utf8") !== content);
  if (stale.length) {
    console.error("build-catalog: generated files are out of date. Run `npm run build` and commit the result:");
    for (const [path] of stale) console.error(`  - ${rel(path)}`);
    process.exit(1);
  }
  console.log(`build-catalog: ${outputs.size} generated file(s) are up to date`);
} else {
  for (const [path, content] of outputs) {
    mkdirSync(dirname(path), { recursive: true });
    writeFileSync(path, content);
    console.log(`wrote ${rel(path)}`);
  }
}
