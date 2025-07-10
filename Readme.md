# DevContainer Project

This project provides a development container setup using the Dev Containers CLI.

## Prerequisites

- Docker Desktop installed and running
- Node.js and npm (for installing the Dev Containers CLI)

## Quick Start

Use the provided Makefile for easy container management:

```bash
# Install Dev Containers CLI (if not already installed)
make install-cli

# Start the devcontainer (automatically starts Docker if needed)
make up

# Open a shell in the container
make shell

# Execute a command in the container
make exec CMD='your-command-here'

# Stop the devcontainer
make down

# Clean up container and volumes
make clean
```

## Manual Commands

If you prefer to run commands directly:

1. Install the Dev Containers CLI:
   ```bash
   npm install -g @devcontainers/cli
   ```

2. Start the devcontainer:
   ```bash
   devcontainer up --workspace-folder .
   ```

3. Execute commands inside the container:
   ```bash
   devcontainer exec --workspace-folder . <command>
   ```

4. Open a shell in the container:
   ```bash
   devcontainer exec --workspace-folder . zsh
   ```

## Available Make Targets

- `make help` - Show all available commands
- `make check-docker` - Check if Docker is running
- `make start-docker` - Start Docker Desktop (macOS)
- `make install-cli` - Install Dev Containers CLI globally
- `make up` - Start the devcontainer
- `make shell` - Open a shell in the running container
- `make exec CMD=<command>` - Execute a command in the container
- `make down` - Stop the devcontainer
- `make clean` - Remove the devcontainer and its volumes