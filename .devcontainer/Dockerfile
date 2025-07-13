FROM node:20

ARG TZ
ENV TZ="$TZ"

# Install basic development tools and iptables/ipset  
RUN apt update && apt install -y less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  gh \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  jq \
  ca-certificates \
  curl \
  wget \
  libnspr4 \
  libnss3 \
  libdbus-1-3 \
  libatk1.0-0 \
  libatk-bridge2.0-0 \
  libcups2 \
  libxkbcommon0 \
  libatspi2.0-0 \
  libxcomposite1 \
  libxdamage1 \
  libxfixes3 \
  libxrandr2 \
  libgbm1 \
  libasound2

# Install newer neovim (>= 0.8.0) from GitHub releases
RUN ARCH=$(dpkg --print-architecture) && \
  if [ "$ARCH" = "amd64" ]; then NVIM_ARCH="linux64"; else NVIM_ARCH="$ARCH"; fi && \
  wget "https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-$NVIM_ARCH.tar.gz" -O /tmp/nvim.tar.gz && \
  tar -xzf /tmp/nvim.tar.gz -C /opt && \
  ln -sf /opt/nvim-$NVIM_ARCH/bin/nvim /usr/local/bin/nvim && \
  rm /tmp/nvim.tar.gz

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt update && \
  apt install -y docker-ce-cli

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

# Add node user to the group that owns the Docker socket (GID 1)
# This ensures Docker socket access works with the host's group
RUN usermod -aG $(getent group 1 | cut -d: -f1) node

ARG USERNAME=node

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create workspace and config directories and set permissions
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_0.18.2_${ARCH}.deb" && \
  rm "git-delta_0.18.2_${ARCH}.deb"

# Set up non-root user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Default powerline10k theme
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -a "alias cld='claude --dangerously-skip-permissions'" \
  -a "alias vim='nvim'" \
  -a "alias vi='nvim'" \
  -x

# Install Claude
RUN npm install -g @anthropic-ai/claude-code

# Setup neovim configuration
USER root
RUN mkdir -p /home/node/.config/nvim
COPY nvim-init.lua /home/node/.config/nvim/init.lua
RUN chown -R node:node /home/node/.config

# Pre-install Treesitter parsers and plugins to avoid network dependency at runtime
USER node
RUN nvim --headless -c "lua require('lazy').setup({})" -c "qa" || true
RUN nvim --headless -c "TSInstall markdown markdown_inline lua vim bash json yaml dockerfile javascript typescript python" -c "qa" || true
USER root

# Copy and set up firewall script
COPY init-firewall.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  echo "node ALL=(root) NOPASSWD: /bin/chgrp daemon /var/run/docker.sock" >> /etc/sudoers.d/node-firewall && \
  echo "node ALL=(root) NOPASSWD: /usr/bin/apt, /usr/bin/apt-get" >> /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall
USER node
