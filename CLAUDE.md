# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DevContainer environment project that provides a secure, isolated development environment with Claude AI integration. The container includes Node.js 20, development tools, and implements strict network security via iptables firewall rules.

## Key Commands

### Container Management
- `make up` - Start Docker and bring up the devcontainer
- `make shell` - Open a Zsh shell in the running container
- `make exec CMD='command'` - Execute commands in the container
- `make down` - Stop the devcontainer
- `make clean` - Remove container and volumes
- `make logs` - Show container logs

### Development Setup
- `make install-cli` - Install Dev Containers CLI globally (prerequisite)
- `make claude_setup` - Copy Claude commands to ~/.claude/commands/

### Running Commands in Container
Always use `make exec CMD='command'` or `make shell` to run commands inside the container. For example:
- `make exec CMD='npm install'`
- `make exec CMD='node app.js'`

## Architecture and Structure

### Container Configuration
The DevContainer is configured via `.devcontainer/devcontainer.json` with:
- VS Code extensions pre-installed (ESLint, Prettier, GitLens)
- Auto-formatting on save enabled
- Port 3000 forwarded for web applications
- Persistent volumes for bash history and Claude config

### Network Security
The container implements strict outbound firewall rules (`.devcontainer/init-firewall.sh`):
- Only allows connections to specific domains (GitHub, npm, Anthropic API)
- Blocks all other outbound traffic by default
- Uses iptables with ipset for efficient domain-based filtering

### Claude Integration
- Claude CLI is pre-installed in the container
- Custom commands are available in `claude_commands/explore-plan-code-test.md`
- Local Claude config is mounted at `/home/node/.claude`

## Development Workflow

1. Start the container: `make up`
2. Open a shell: `make shell`
3. Work within the container using the pre-configured development environment
4. The container includes git, fzf, zsh with PowerLevel10k, and other dev tools

## Important Notes

- The container runs as the 'node' user (UID 1000)
- Network access is restricted - only whitelisted domains are accessible
- VS Code will automatically use the container's environment when opened
- Port 3000 is forwarded for web application development