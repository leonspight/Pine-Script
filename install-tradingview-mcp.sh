#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# TradingView MCP — local install for Claude Code
# ─────────────────────────────────────────────────────────────

INSTALL_DIR="${HOME}/tradingview-mcp"
MCP_CONFIG="${HOME}/.claude/.mcp.json"

echo "→ Cloning repo to ${INSTALL_DIR}"
if [ -d "${INSTALL_DIR}" ]; then
  echo "  (already exists — pulling latest)"
  git -C "${INSTALL_DIR}" pull --ff-only
else
  git clone https://github.com/tradesdontlie/tradingview-mcp.git "${INSTALL_DIR}"
fi

echo "→ Installing npm dependencies"
cd "${INSTALL_DIR}"
npm install

echo "→ Merging MCP config at ${MCP_CONFIG}"
mkdir -p "$(dirname "${MCP_CONFIG}")"

node --input-type=module -e "
import fs from 'fs';
const path = '${MCP_CONFIG}';
const entry = {
  command: 'node',
  args: ['${INSTALL_DIR}/src/server.js']
};
const cfg = fs.existsSync(path)
  ? JSON.parse(fs.readFileSync(path, 'utf8'))
  : {};
cfg.mcpServers = cfg.mcpServers || {};
cfg.mcpServers.tradingview = entry;
fs.writeFileSync(path, JSON.stringify(cfg, null, 2) + '\n');
console.log('  ✓ tradingview entry written');
"

echo ""
echo "✓ Install complete."
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code so it picks up the new MCP server."
echo "  2. In Claude Code, ask: 'Use tv_launch to start TradingView Desktop'"
echo "     (or launch it manually with --remote-debugging-port=9222)"
echo "  3. Verify with: 'Run tv_health_check'"
