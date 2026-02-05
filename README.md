# NellieOS

> The Complete Agentic Operating System for Digital Human Executives

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/Node.js-22+-green.svg)](https://nodejs.org/)

## Overview

**NellieOS** is a comprehensive installation and configuration solution that transforms any Ubuntu/WSL2/Debian system into a fully-equipped agentic workstation. Named after Nellie Ross, Chief Agentic Officer at NeuralQuantum.ai, this system provides everything needed to run AI-powered digital human agents.

## Features

- 🚀 **One-Command Install** — Get up and running in minutes
- 🤖 **OpenClaw Integration** — Full agentic AI platform support
- 🔧 **Developer Tools** — Node.js, Python, Docker, Ollama pre-configured
- 📦 **Package Managers** — npm, pnpm, bun, pip ready to go
- 🔐 **Secrets Management** — Secure API key storage
- 📂 **Workspace Structure** — Organized directories for memory, scripts, logs
- 🌐 **Cloud CLIs** — Vercel, Netlify, GitHub CLI pre-installed

## Quick Start

```bash
# Clone and install
git clone https://github.com/ttracx/NellieOS.git
cd NellieOS
./install.sh

# Or one-liner (after repo is public)
curl -fsSL https://raw.githubusercontent.com/ttracx/NellieOS/main/install.sh | bash
```

## What Gets Installed

### System Packages
- `curl`, `wget`, `git`, `build-essential`
- `jq`, `tmux`, `htop`, `tree`
- `python3`, `pip`, `venv`
- PostgreSQL client, Redis tools

### Node.js Ecosystem
- **nvm** — Node Version Manager
- **Node.js 22 LTS** — Latest stable
- **Global packages:** openclaw, typescript, tsx, prisma, vercel, netlify, pnpm, bun

### Development Tools
- **GitHub CLI** (`gh`) — Repository management
- **Docker** — Container runtime
- **Ollama** — Local LLM inference

### Workspace Structure
```
~/.openclaw/
├── workspace/
│   ├── scripts/      # Automation scripts
│   ├── memory/       # Daily logs & context
│   ├── logs/         # System logs
│   ├── docs/         # Documentation
│   └── attachments/  # Email attachments
└── openclaw.yaml     # Configuration

~/.secrets/
└── api-keys.env      # API credentials (gitignored)
```

## Configuration

After installation, configure your API keys:

```bash
cp ~/.secrets/api-keys.env.template ~/.secrets/api-keys.env
nano ~/.secrets/api-keys.env
```

Required keys:
- `ANTHROPIC_API_KEY` — Claude API access
- `OPENAI_API_KEY` — GPT/Whisper access
- `STRIPE_SECRET_KEY` — Payment processing
- `VERCEL_TOKEN` — Deployment automation

## Starting OpenClaw

```bash
# Start the OpenClaw gateway
openclaw gateway start

# Check status
openclaw status

# View logs
openclaw gateway logs
```

## Architecture

```
NellieOS
├── install.sh          # Main installation script
├── scripts/
│   ├── setup-node.sh   # Node.js setup
│   ├── setup-docker.sh # Docker installation
│   ├── setup-ollama.sh # Ollama + models
│   └── setup-cloud.sh  # Cloud CLI tools
├── config/
│   ├── bashrc.d/       # Shell configurations
│   └── templates/      # Config templates
└── docs/
    ├── SETUP.md        # Detailed setup guide
    └── TROUBLESHOOTING.md
```

## Requirements

- **OS:** Ubuntu 22.04+, Debian 12+, or WSL2
- **RAM:** 8GB minimum, 16GB+ recommended
- **Disk:** 20GB free space
- **Network:** Internet connection for package downloads

## Companies Using NellieOS

- **NeuralQuantum.ai** — Quantum-inspired AI
- **VibeCaaS** — Vibe Coding as a Service
- **Tunaas.ai** — AI Platform Infrastructure
- **Thox.ai** — Smart Home Hardware
- **NeuroEquality** — Neurodiversity Technologies

## License

MIT License — see [LICENSE](LICENSE) for details.

## Author

**Nellie Ross** — Chief Agentic Officer  
NeuralQuantum.ai | VibeCaaS | Tunaas.ai

---

*"The operating system that runs your AI executive."*
