#!/usr/bin/env node
// Checks one plugin directory against the rules in CONTRIBUTING.md: the Agent Plugins 1.0.0
// package format, the SKILL.md format, and the few rules Claude Code and Codex add on top.
//
// The schemas it enforces by hand are under schemas/agent-plugins/1.0.0/.
// build-catalog.mjs imports validatePluginDir(); the file also runs standalone:
//
//   node scripts/validate-plugin.mjs plugins/<name> [...]

import { existsSync, lstatSync, readdirSync, readFileSync, realpathSync, statSync } from "node:fs";
import { basename, join, relative, resolve, sep } from "node:path";
import { pathToFileURL } from "node:url";

export const PLUGIN_SCHEMA = "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json";
export const MCP_SCHEMA = "https://agent-plugins.org/schemas/1.0.0/mcp.schema.json";
// 1-64 chars, lowercase a-z 0-9 . -, alphanumeric at both ends, no "--" or "..".
export const PLUGIN_NAME_RE = /^(?!.*(?:--|\.\.))[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?$/;
// Skill names: 1-64 chars, lowercase a-z 0-9 -, no leading/trailing/double hyphen.
const SKILL_NAME_RE = /^(?!.*--)[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$/;

const MANIFEST_FIELDS = new Set(["$schema", "name", "version", "description", "author", "homepage", "repository", "license", "keywords", "extensions"]);
const MANIFEST_STRING_FIELDS = ["version", "description", "homepage", "repository", "license"];
const AUTHOR_FIELDS = new Set(["name", "email", "url"]);
const MCP_SERVER_SHAPES = {
  stdio: { required: ["type", "command"], allowed: ["type", "command", "args", "env", "cwd"] },
  "streamable-http": { required: ["type", "url"], allowed: ["type", "url", "headers"] },
  sse: { required: ["type", "url"], allowed: ["type", "url", "headers"] },
};
const MCP_CWD_RE = /^(?:\.\/|\$\{PLUGIN_ROOT\}(?:\/|$)|\$\{PLUGIN_DATA\}(?:\/|$))/;
const RESERVED_ENV = new Set(["PLUGIN_ROOT", "PLUGIN_DATA"]);
// At least one of these must exist, or the plugin does nothing in either host.
export const COMPONENT_MARKERS = ["skills", "mcp.json", ".mcp.json", "hooks", "commands", "agents"];

const isObject = (v) => v !== null && typeof v === "object" && !Array.isArray(v);
const isStringArray = (v) => Array.isArray(v) && v.every((s) => typeof s === "string");

export function validatePluginDir(pluginDir) {
  const errors = [];
  const warnings = [];
  const fail = (m) => errors.push(m);
  const warn = (m) => warnings.push(m);
  const root = resolve(pluginDir);
  const at = (p) => relative(process.cwd(), p) || ".";
  const result = { errors, warnings, manifest: null };

  if (!existsSync(root) || !statSync(root).isDirectory()) {
    fail(`${at(root)}: not a directory`);
    return result;
  }

  // ---- plugin.json -------------------------------------------------------------
  const manifestPath = join(root, "plugin.json");
  const where = at(manifestPath);
  if (!existsSync(manifestPath)) {
    fail(`${where}: missing. Every plugin needs a portable plugin.json at its root`);
    return result;
  }
  let manifest;
  try {
    manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
  } catch (err) {
    fail(`${where}: ${err.message}`);
    return result;
  }
  if (!isObject(manifest)) {
    fail(`${where}: must be a JSON object`);
    return result;
  }
  result.manifest = manifest;

  for (const key of Object.keys(manifest)) {
    if (!MANIFEST_FIELDS.has(key)) fail(`${where}: unknown top-level field "${key}". The manifest schema is closed; client-specific data goes under "extensions"`);
  }
  if (manifest.$schema !== PLUGIN_SCHEMA) fail(`${where}: "$schema" must be ${PLUGIN_SCHEMA}`);
  if (typeof manifest.name !== "string" || !PLUGIN_NAME_RE.test(manifest.name)) {
    fail(`${where}: "name" must be 1-64 chars of lowercase a-z, 0-9, "-" and ".", alphanumeric at both ends, with no "--" or ".." (got ${JSON.stringify(manifest.name)})`);
  }
  for (const key of MANIFEST_STRING_FIELDS) {
    if (manifest[key] !== undefined && typeof manifest[key] !== "string") fail(`${where}: "${key}" must be a string`);
  }
  if (manifest.keywords !== undefined && !isStringArray(manifest.keywords)) fail(`${where}: "keywords" must be an array of strings`);
  if (manifest.author !== undefined) {
    if (!isObject(manifest.author)) {
      fail(`${where}: "author" must be an object`);
    } else {
      for (const [key, value] of Object.entries(manifest.author)) {
        if (!AUTHOR_FIELDS.has(key)) fail(`${where}: "author.${key}" is not allowed; only name, email and url are`);
        else if (typeof value !== "string") fail(`${where}: "author.${key}" must be a string`);
      }
      // Claude Code's manifest requires author.name whenever author is present.
      if (typeof manifest.author.name !== "string" || !manifest.author.name) fail(`${where}: "author.name" is required by Claude Code when "author" is set`);
    }
  }
  if (manifest.extensions !== undefined) {
    if (!isObject(manifest.extensions)) {
      fail(`${where}: "extensions" must be an object keyed by reverse-domain namespace`);
    } else {
      for (const [ns, value] of Object.entries(manifest.extensions)) {
        if (!isObject(value)) fail(`${where}: "extensions.${ns}" must be an object`);
      }
    }
  }
  // Marketplace rules: both hosts use version for update checks; description is what users see.
  if (!manifest.version) fail(`${where}: "version" is required; bump it to ship an update`);
  if (!manifest.description) fail(`${where}: "description" is required; it is what users see in the catalog`);
  if (!manifest.license && !existsSync(join(root, "LICENSE"))) {
    warn(`${at(root)}: no "license" in plugin.json and no LICENSE file. Every plugin here should carry one`);
  }

  // ---- containment: nothing in the package may resolve outside the root -------
  const realRoot = realpathSync(root);
  const inside = (p) => p === realRoot || p.startsWith(realRoot + sep);
  const walk = (dir) => {
    for (const entry of readdirSync(dir)) {
      const path = join(dir, entry);
      const st = lstatSync(path);
      if (st.isSymbolicLink()) {
        let target;
        try {
          target = realpathSync(path);
        } catch {
          fail(`${at(path)}: broken symlink`);
          continue;
        }
        if (!inside(target)) fail(`${at(path)}: symlink resolves outside the plugin root (${target}); clients must reject it`);
        continue;
      }
      if (st.isDirectory() && entry !== "node_modules") walk(path);
    }
  };
  walk(root);

  // ---- components ------------------------------------------------------------
  if (!COMPONENT_MARKERS.some((m) => existsSync(join(root, m)))) {
    fail(`${at(root)}: no components found (expected one of ${COMPONENT_MARKERS.join(", ")})`);
  }

  const skillsDir = join(root, "skills");
  if (existsSync(skillsDir)) {
    if (!statSync(skillsDir).isDirectory()) {
      fail(`${at(skillsDir)}: exists but is not a directory, so no skill will load`);
    } else {
      let found = 0;
      for (const entry of readdirSync(skillsDir)) {
        const skillDir = join(skillsDir, entry);
        if (!statSync(skillDir).isDirectory()) continue;
        const skillFile = join(skillDir, "SKILL.md");
        if (!existsSync(skillFile) || !statSync(skillFile).isFile()) {
          warn(`${at(skillDir)}: no SKILL.md, so it is not a skill and will be ignored`);
          continue;
        }
        found++;
        validateSkill(skillFile, entry, fail, warn, at);
        // clients never search deeper than the immediate child, so a nested SKILL.md is dead.
        findNested(skillDir, "SKILL.md").forEach((p) => warn(`${at(p)}: nested SKILL.md is never discovered; only skills/<name>/SKILL.md is`));
      }
      if (found === 0) warn(`${at(skillsDir)}: contains no skill`);
    }
  }

  const mcpPath = join(root, "mcp.json");
  const claudeMcpPath = join(root, ".mcp.json");
  if (existsSync(mcpPath)) {
    validateMcp(mcpPath, fail, at);
    if (!existsSync(claudeMcpPath)) warn(`${at(root)}: mcp.json is read by Codex only; Claude Code reads .mcp.json. Write both to serve both hosts`);
  } else if (existsSync(claudeMcpPath)) {
    warn(`${at(root)}: .mcp.json is read by Claude Code only; Codex reads mcp.json (Agent Plugins format). Write both to serve both hosts`);
  }

  return result;
}

function validateSkill(skillFile, dirName, fail, warn, at) {
  const where = at(skillFile);
  const text = readFileSync(skillFile, "utf8");
  const fm = parseFrontmatter(text);
  if (!fm) {
    fail(`${where}: must start with YAML frontmatter (--- name/description ---)`);
    return;
  }
  const { name, description, compatibility } = fm;
  if (typeof name !== "string" || !name || name.length > 64 || !SKILL_NAME_RE.test(name)) {
    fail(`${where}: "name" must be 1-64 chars of lowercase a-z, 0-9 and "-", with no leading, trailing or double hyphen (got ${JSON.stringify(name)})`);
  } else if (name !== dirName) {
    fail(`${where}: "name" (${name}) must equal its directory name (${dirName})`);
  }
  if (typeof description !== "string" || !description.trim()) {
    fail(`${where}: "description" is required and non-empty`);
  } else if (description.length > 1024) {
    fail(`${where}: "description" is ${description.length} chars; the limit is 1024`);
  }
  if (compatibility !== undefined && (typeof compatibility !== "string" || !compatibility || compatibility.length > 500)) {
    fail(`${where}: "compatibility" must be 1-500 chars when present`);
  }
  const bodyLines = text.split("\n").length;
  if (bodyLines > 500) warn(`${where}: ${bodyLines} lines; keep it under 500, with detail moved into referenced files`);
}

function validateMcp(mcpPath, fail, at) {
  const where = at(mcpPath);
  let doc;
  try {
    doc = JSON.parse(readFileSync(mcpPath, "utf8"));
  } catch (err) {
    fail(`${where}: ${err.message}`);
    return;
  }
  if (!isObject(doc)) return fail(`${where}: must be a JSON object`);
  for (const key of Object.keys(doc)) if (key !== "$schema" && key !== "mcpServers") fail(`${where}: unknown field "${key}"`);
  if (doc.$schema !== MCP_SCHEMA) fail(`${where}: "$schema" must be ${MCP_SCHEMA} (same format version as plugin.json)`);
  if (!isObject(doc.mcpServers)) return fail(`${where}: "mcpServers" must be an object`);
  for (const [name, server] of Object.entries(doc.mcpServers)) {
    const here = `${where}: server "${name}"`;
    if (!isObject(server)) {
      fail(`${here}: must be an object`);
      continue;
    }
    const shape = MCP_SERVER_SHAPES[server.type];
    if (!shape) {
      fail(`${here}: "type" must be one of ${Object.keys(MCP_SERVER_SHAPES).join(", ")} (got ${JSON.stringify(server.type)})`);
      continue;
    }
    for (const key of shape.required) if (typeof server[key] !== "string" || !server[key]) fail(`${here}: "${key}" is required and must be a non-empty string`);
    for (const key of Object.keys(server)) if (!shape.allowed.includes(key)) fail(`${here}: "${key}" is not allowed on a ${server.type} server`);
    if (server.args !== undefined && !isStringArray(server.args)) fail(`${here}: "args" must be an array of strings`);
    if (server.headers !== undefined && (!isObject(server.headers) || !Object.values(server.headers).every((v) => typeof v === "string"))) {
      fail(`${here}: "headers" must map strings to strings`);
    }
    if (server.env !== undefined) {
      if (!isObject(server.env) || !Object.values(server.env).every((v) => typeof v === "string")) fail(`${here}: "env" must map strings to strings`);
      else for (const key of Object.keys(server.env)) if (RESERVED_ENV.has(key)) fail(`${here}: "env.${key}" is reserved; the client sets it`);
    }
    if (server.cwd !== undefined) {
      if (typeof server.cwd !== "string" || !MCP_CWD_RE.test(server.cwd)) fail(`${here}: "cwd" must start with "./", "\${PLUGIN_ROOT}" or "\${PLUGIN_DATA}"`);
      else if (server.cwd.split(/[\\/]/).includes("..")) fail(`${here}: "cwd" must stay inside the plugin root`);
    }
    if (typeof server.command === "string" && server.command) {
      // one executable token, either a bare name or a plugin-relative "./" path. No shell strings.
      if (server.command.startsWith("./")) {
        if (server.command.split(/[\\/]/).includes("..")) fail(`${here}: "command" must stay inside the plugin root`);
      } else if (/[\\/\s]/.test(server.command) || server.command.includes("${")) {
        fail(`${here}: "command" must be a bare executable name or a plugin-relative path starting with "./" (got ${JSON.stringify(server.command)})`);
      }
    }
    if (typeof server.url === "string" && server.url) validateMcpUrl(server.url, here, fail);
    if (isObject(server.headers)) {
      const seenNames = new Set();
      for (const name of Object.keys(server.headers)) {
        const lower = name.toLowerCase();
        if (seenNames.has(lower)) fail(`${here}: header "${name}" appears more than once under different casing`);
        seenNames.add(lower);
      }
    }
  }
}

// absolute http(s) URL, no user info or fragment, https unless the host is loopback.
function validateMcpUrl(url, here, fail) {
  let parsed;
  try {
    parsed = new URL(url);
  } catch {
    return fail(`${here}: "url" must be an absolute URL (got ${JSON.stringify(url)})`);
  }
  if (parsed.protocol !== "http:" && parsed.protocol !== "https:") return fail(`${here}: "url" must use http or https`);
  if (parsed.username || parsed.password) fail(`${here}: "url" must not contain user information`);
  if (parsed.hash) fail(`${here}: "url" must not contain a fragment`);
  const host = parsed.hostname.replace(/^\[|\]$/g, "");
  const loopback = host === "localhost" || /^127\.\d+\.\d+\.\d+$/.test(host) || host === "::1";
  if (parsed.protocol === "http:" && !loopback) fail(`${here}: "url" must use https except on localhost or a loopback address`);
}

// Minimal YAML frontmatter reader: top-level "key: value" lines, quoted scalars, and "|"/">" block scalars.
function parseFrontmatter(text) {
  if (!text.startsWith("---\n") && !text.startsWith("---\r\n")) return null;
  const end = text.indexOf("\n---", 3);
  if (end === -1) return null;
  const lines = text.slice(text.indexOf("\n") + 1, end).split(/\r?\n/);
  const out = {};
  for (let i = 0; i < lines.length; i++) {
    const m = /^([A-Za-z0-9_-]+):\s*(.*)$/.exec(lines[i]);
    if (!m) continue;
    let value = m[2].trim();
    if (/^[|>][+-]?$/.test(value)) {
      const block = [];
      while (i + 1 < lines.length && (/^\s+/.test(lines[i + 1]) || lines[i + 1] === "")) block.push(lines[++i].trim());
      value = block.join(value.startsWith(">") ? " " : "\n").trim();
    } else if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    out[m[1]] = value;
  }
  return out;
}

function findNested(dir, fileName, depth = 0, acc = []) {
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);
    if (lstatSync(path).isDirectory()) findNested(path, fileName, depth + 1, acc);
    else if (depth > 0 && entry === fileName) acc.push(path);
  }
  return acc;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const dirs = process.argv.slice(2);
  if (dirs.length === 0) {
    console.error("usage: node scripts/validate-plugin.mjs <plugin-dir> [...]");
    process.exit(2);
  }
  let failed = false;
  for (const dir of dirs) {
    const { errors, warnings } = validatePluginDir(dir);
    console.log(`${basename(resolve(dir))}: ${errors.length ? `${errors.length} error(s)` : "ok"}${warnings.length ? `, ${warnings.length} warning(s)` : ""}`);
    for (const e of errors) console.log(`  error    ${e}`);
    for (const w of warnings) console.log(`  warning  ${w}`);
    if (errors.length) failed = true;
  }
  process.exit(failed ? 1 : 0);
}
