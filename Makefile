.PHONY: help check-docker start-docker install-cli up up-unsafe exec shell shell-unsafe down clean claude_setup logs workspace

# Default target
help:
	@echo "Available targets:"
	@echo "  make install-cli  - Install Dev Containers CLI globally"
	@echo "  make up          - Start Docker if needed and bring up the devcontainer (with firewall)"
	@echo "  make up-unsafe   - Start devcontainer with full internet access (no firewall)"
	@echo "  make shell       - Open a shell in the running container"
	@echo "  make shell-unsafe - Open a shell in the unsafe container"
	@echo "  make exec CMD=<command> - Execute a command in the container"
	@echo "  make down        - Stop the devcontainer"
	@echo "  make clean       - Remove the devcontainer and its volumes"
	@echo "  make logs        - Show container logs"
	@echo "  make check-docker - Check if Docker is running"
	@echo "  make start-docker - Start Docker Desktop"
	@echo "  make claude_setup - Copy claude_commands to ~/.claude/commands/"
	@echo "  make workspace   - Create an empty workspace folder"

# Check if Docker is running
check-docker:
	@echo "Checking Docker status..."
	@if docker ps >/dev/null 2>&1; then \
		echo "✓ Docker is running"; \
	else \
		echo "✗ Docker is not running"; \
		exit 1; \
	fi

# Start Docker Desktop on macOS
start-docker:
	@echo "Starting Docker Desktop..."
	@if ! docker ps >/dev/null 2>&1; then \
		open -a Docker || (echo "Error: Docker Desktop not found. Please install Docker Desktop." && exit 1); \
		echo "Waiting for Docker to start..."; \
		while ! docker ps >/dev/null 2>&1; do \
			printf "."; \
			sleep 2; \
		done; \
		echo ""; \
		echo "✓ Docker is now running"; \
	else \
		echo "✓ Docker is already running"; \
	fi

# Install Dev Containers CLI
install-cli:
	@echo "Checking if Dev Containers CLI is installed..."
	@if ! command -v devcontainer >/dev/null 2>&1; then \
		echo "Installing Dev Containers CLI..."; \
		npm install -g @devcontainers/cli; \
		echo "✓ Dev Containers CLI installed"; \
	else \
		echo "✓ Dev Containers CLI is already installed"; \
	fi

# Start the devcontainer (with automatic Docker startup)
up: start-docker
	@echo "Starting devcontainer..."
	@if [ ! -d workspace ] || [ -z "$$(ls -A workspace 2>/dev/null)" ]; then \
		echo "Creating empty workspace with git repository..."; \
		mkdir -p workspace; \
		cd workspace && git init; \
		echo "✓ Workspace created and initialized with git"; \
	else \
		echo "✓ Workspace already exists with content, skipping initialization"; \
	fi
	@devcontainer up --workspace-folder .
	@echo "✓ Devcontainer is running"
	@echo "Tip: Run 'make shell' to open a shell in the container"

# Start the unsafe devcontainer (with full internet access)
up-unsafe: start-docker
	@echo "WARNING: Starting devcontainer in UNSAFE mode with full internet access!"
	@echo "This container can access any website and is less secure."
	@if [ ! -d workspace ] || [ -z "$$(ls -A workspace 2>/dev/null)" ]; then \
		echo "Creating empty workspace with git repository..."; \
		mkdir -p workspace; \
		cd workspace && git init; \
		echo "✓ Workspace created and initialized with git"; \
	else \
		echo "✓ Workspace already exists with content, skipping initialization"; \
	fi
	@UNSAFE_MODE=true devcontainer up --workspace-folder .
	@echo "✓ Unsafe devcontainer is running"
	@echo "Tip: Run 'make shell-unsafe' to open a shell in the unsafe container"

# Execute a command in the container
exec: check-docker
	@if [ -z "$(CMD)" ]; then \
		echo "Error: Please specify a command using CMD=<command>"; \
		echo "Example: make exec CMD='npm install'"; \
		exit 1; \
	fi
	@echo "Executing command: $(CMD)"
	@devcontainer exec --workspace-folder . $(CMD)

# Open a shell in the container
shell: check-docker
	@echo "Opening shell in container..."
	@devcontainer exec --workspace-folder . zsh

# Open a shell in the unsafe container
shell-unsafe: check-docker
	@echo "Opening shell in UNSAFE container (full internet access)..."
	@devcontainer exec --workspace-folder . zsh

# Stop the devcontainer
down: check-docker
	@echo "Stopping devcontainer..."
	@docker ps -q --filter "label=devcontainer.local_folder=$(PWD)" | xargs -r docker stop
	@echo "✓ Devcontainer stopped"

# Clean up the devcontainer and volumes
clean: check-docker
	@echo "Cleaning up devcontainer..."
	@docker ps -aq --filter "label=devcontainer.local_folder=$(PWD)" | xargs -r docker rm -f
	@docker volume ls -q --filter "name=claude-code-bashhistory" | xargs -r docker volume rm -f 2>/dev/null || true
	@echo "✓ Cleanup complete"

# Setup Claude commands
claude_setup:
	@echo "Setting up Claude commands..."
	@mkdir -p ~/.claude/commands
	@cp -r claude_commands/* ~/.claude/commands/
	@echo "✓ Claude commands copied to ~/.claude/commands/"

# Show container logs
logs: check-docker
	@echo "Showing container logs..."
	@docker ps -q --filter "label=devcontainer.local_folder=$(PWD)" | xargs -r docker logs -f

# Create an empty workspace folder
workspace:
	@echo "Creating workspace folder..."
	@mkdir -p workspace
	@echo "✓ Empty workspace folder created"