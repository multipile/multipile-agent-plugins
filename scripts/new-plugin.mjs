#!/usr/bin/env node
// Scaffolds a new plugin from templates/plugin, registers it in marketplace.config.json,
// and regenerates the catalogs.
//
// Usage: node scripts/new-plugin.mjs <name> [--description "..."] [--display-name "..."] [--category "..."]

import { cpSync, existsSync, readFileSync, readdirSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const NAME_RE = /^(?!.*(?:--|\.\.))[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?$/;

const args = process.argv.slice(2);
const name = args.find((a) => !a.startsWith("--"));
const opt = (flag, fallback) => {
  const i = args.indexOf(flag);
  return i !== -1 && args[i + 1] !== undefined ? args[i + 1] : fallback;
};

if (!name || !NAME_RE.test(name)) {
  console.error("usage: node scripts/new-plugin.mjs <lowercase-kebab-name> [--description ...] [--display-name ...] [--category ...]");
  process.exit(1);
}

const config = JSON.parse(readFileSync(join(ROOT, "marketplace.config.json"), "utf8"));
const pluginRoot = config.pluginRoot ?? "./plugins";
const target = join(ROOT, pluginRoot, name);
if (existsSync(target)) {
  console.error(`${pluginRoot}/${name} already exists`);
  process.exit(1);
}
if (config.plugins.some((p) => p.dir === name)) {
  console.error(`${name} is already listed in marketplace.config.json`);
  process.exit(1);
}

const displayName = opt("--display-name", name.split(/[-.]/).map((w) => w[0].toUpperCase() + w.slice(1)).join(" "));
const description = opt("--description", `${displayName} plugin.`);
const category = opt("--category", config.defaults?.category ?? "Productivity");
const replacements = { __NAME__: name, __DISPLAY_NAME__: displayName, __DESCRIPTION__: description, __CATEGORY__: category };
const substitute = (text) => Object.entries(replacements).reduce((s, [k, v]) => s.replaceAll(k, v), text);

cpSync(join(ROOT, "templates", "plugin"), target, { recursive: true });
const walk = (dir) => {
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);
    if (statSync(path).isDirectory()) walk(path);
    else writeFileSync(path, substitute(readFileSync(path, "utf8")));
  }
};
walk(target);

config.plugins.push({ dir: name, category });
writeFileSync(join(ROOT, "marketplace.config.json"), JSON.stringify(config, null, 2) + "\n");

const build = spawnSync(process.execPath, [join(ROOT, "scripts", "build-catalog.mjs")], { stdio: "inherit" });
if (build.status !== 0) process.exit(build.status ?? 1);

console.log(`
Created ${pluginRoot}/${name} and added it to marketplace.config.json.
Next:
  1. Edit ${pluginRoot}/${name}/plugin.json and the skill in ${pluginRoot}/${name}/skills/
  2. npm run validate
`);
