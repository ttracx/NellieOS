#!/bin/bash
# Nellie Ross (OpenClaw) Installation Script
# Run on a fresh Ubuntu/Debian system or WSL2
# Usage: curl -fsSL https://raw.githubusercontent.com/ttracx/nellie-install/main/install.sh | bash

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Nellie Ross - Chief Agentic Officer Installation Script    ║"
echo "║  NeuralQuantum.ai | VibeCaaS | Tunaas.ai                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    log_error "Please do not run as root. Run as your normal user."
    exit 1
fi

# Update system
log_info "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install essential packages
log_info "Installing essential packages..."
sudo apt-get install -y \
    curl wget git build-essential \
    software-properties-common apt-transport-https \
    ca-certificates gnupg lsb-release \
    jq unzip zip htop tree tmux \
    python3 python3-pip python3-venv \
    postgresql-client redis-tools

# Install Node.js via nvm
log_info "Installing Node.js via nvm..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi
source ~/.nvm/nvm.sh
nvm install 22
nvm use 22
nvm alias default 22

# Install global npm packages
log_info "Installing global npm packages..."
npm install -g \
    openclaw \
    typescript tsx turbo \
    prisma drizzle-kit \
    vercel netlify-cli \
    pnpm bun

# Install GitHub CLI
log_info "Installing GitHub CLI..."
if ! command -v gh &> /dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update && sudo apt-get install -y gh
fi

# Install Docker (if not in WSL2 with Docker Desktop)
if ! command -v docker &> /dev/null; then
    log_info "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
fi

# Install Ollama
log_info "Installing Ollama..."
if ! command -v ollama &> /dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
fi

# Create OpenClaw workspace
log_info "Creating OpenClaw workspace..."
mkdir -p ~/.openclaw/workspace/{scripts,memory,logs,docs,attachments}
mkdir -p ~/.secrets

# Create placeholder config files
cat > ~/.openclaw/workspace/AGENTS.md << 'AGENTS_EOF'
# AGENTS.md - Your Workspace

This folder is home. Read SOUL.md on startup.
AGENTS_EOF

# Create secrets template
cat > ~/.secrets/api-keys.env.template << 'SECRETS_EOF'
# API Keys - Copy to api-keys.env and fill in values
# DO NOT COMMIT api-keys.env

# Anthropic
ANTHROPIC_API_KEY=

# OpenAI
OPENAI_API_KEY=

# Stripe
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=

# Vercel
VERCEL_TOKEN=

# GitHub
GITHUB_TOKEN=

# Neon Database
DATABASE_URL=

# HuggingFace
HF_TOKEN=

# xAI/Grok
XAI_API_KEY=

# ElevenLabs
ELEVENLABS_API_KEY=
SECRETS_EOF

# Initialize OpenClaw
log_info "Initializing OpenClaw..."
cd ~/.openclaw/workspace
if [ ! -f "openclaw.yaml" ]; then
    openclaw init --non-interactive || log_warn "OpenClaw init may need manual configuration"
fi

# Clone essential repos
log_info "Would you like to clone the NeuralQuantum repos? (y/n)"
read -r CLONE_REPOS
if [ "$CLONE_REPOS" = "y" ]; then
    mkdir -p ~/projects
    cd ~/projects
    
    repos=(
        "ttracx/Craig-O-Apps"
        "ttracx/Craig-O-Monitor"
        "ttracx/VibeVicki"
        "ttracx/VibeCaaS"
        "ttracx/nellie-avatar"
    )
    
    for repo in "${repos[@]}"; do
        if [ ! -d "$(basename $repo)" ]; then
            gh repo clone "$repo" || log_warn "Could not clone $repo"
        fi
    done
fi

# Print completion message
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Installation Complete!                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
log_info "Next steps:"
echo "  1. Copy ~/.secrets/api-keys.env.template to ~/.secrets/api-keys.env"
echo "  2. Fill in your API keys"
echo "  3. Run: source ~/.secrets/api-keys.env"
echo "  4. Configure OpenClaw: openclaw config"
echo "  5. Start gateway: openclaw gateway start"
echo ""
log_info "For GitHub auth: gh auth login"
log_info "For Vercel auth: vercel login"
echo ""
echo "Welcome aboard! — Nellie Ross, CAO"
