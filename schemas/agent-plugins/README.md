# Agent Plugins schemas

The JSON Schemas for the Agent Plugins 1.0.0 format. They are reference material: `scripts/validate-plugin.mjs` implements the same rules by hand so the build has no dependencies, and hosts never fetch a schema at load time.

| File | `$schema` id | Governs |
| :- | :- | :- |
| `1.0.0/plugin.schema.json` | `https://agent-plugins.org/schemas/1.0.0/plugin.schema.json` | `plugins/<name>/plugin.json` |
| `1.0.0/mcp.schema.json` | `https://agent-plugins.org/schemas/1.0.0/mcp.schema.json` | `plugins/<name>/mcp.json` |
