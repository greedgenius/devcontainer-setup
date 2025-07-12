#!/bin/bash

echo "MCP (Model Context Protocol) Setup"
echo "=================================="
echo

# Check if config directory exists
if [ ! -d "$HOME/.claude" ]; then
    echo "Creating ~/.claude directory..."
    mkdir -p "$HOME/.claude"
fi

# Check if MCP config already exists
if [ -f "$HOME/.claude/claude_desktop_config.json" ]; then
    echo "✓ MCP config already exists at ~/.claude/claude_desktop_config.json"
    echo "  To use MCP in the container, this file will be copied there automatically."
else
    echo "No MCP config found. Would you like to create a basic one? (y/n)"
    read -r response
    if [ "$response" = "y" ]; then
        cat > "$HOME/.claude/claude_desktop_config.json" << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/workspace"]
    }
  }
}
EOF
        echo "✓ Created basic MCP config at ~/.claude/claude_desktop_config.json"
        echo "  This gives Claude filesystem access to /workspace in the container."
        echo
        echo "You can add more MCP servers later by editing this file."
    fi
fi

echo
echo "To use MCP in the unsafe container:"
echo "1. Run: make up-unsafe"
echo "2. Run: make shell-unsafe"
echo "3. In the container, Claude will have access to configured MCP servers"
echo
echo "Note: MCP servers need to be installed in the container:"
echo "  npm install -g @modelcontextprotocol/server-filesystem"
echo "  npm install -g @modelcontextprotocol/server-github"