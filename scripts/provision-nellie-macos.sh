#!/bin/bash
# NellieOS Provisioning Script for macOS
# Provisions an existing OpenClaw install with Nellie Ross settings
# Usage: curl -fsSL https://raw.githubusercontent.com/ttracx/NellieOS/main/provision-macos.sh | bash

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        NellieOS Provisioning for macOS                       ║"
echo "║        Chief Agentic Officer - NeuralQuantum.ai              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Config
WORKSPACE="${HOME}/.openclaw/workspace"
NELLIEOS_REPO="https://github.com/ttracx/NellieOS.git"
KNIGHTHUB_IP="100.120.210.28"  # Primary KnightHub via Tailscale

log() { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    # Check if OpenClaw is installed
    if ! command -v openclaw &> /dev/null; then
        warn "OpenClaw not found. Installing..."
        npm install -g openclaw
    fi
    log "OpenClaw installed"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        echo "Node.js is required. Please install Node.js 18+ first."
        exit 1
    fi
    log "Node.js $(node -v) found"
    
    # Check Tailscale
    if command -v tailscale &> /dev/null; then
        log "Tailscale found"
        TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "unknown")
        info "Tailscale IP: $TAILSCALE_IP"
    else
        warn "Tailscale not found - manual network config may be needed"
    fi
}

# Create workspace structure
setup_workspace() {
    info "Setting up workspace..."
    
    mkdir -p "$WORKSPACE"/{memory,scripts,logs,attachments}
    mkdir -p "${HOME}/.secrets"
    
    log "Workspace directories created"
}

# Download Nellie configuration files
download_nellie_config() {
    info "Downloading Nellie Ross configuration..."
    
    # Clone or update NellieOS repo
    if [ -d "$WORKSPACE/NellieOS" ]; then
        cd "$WORKSPACE/NellieOS" && git pull
    else
        git clone "$NELLIEOS_REPO" "$WORKSPACE/NellieOS" 2>/dev/null || {
            warn "Could not clone NellieOS repo - downloading files directly..."
            curl -fsSL "https://raw.githubusercontent.com/ttracx/NellieOS/main/workspace/SOUL.md" -o "$WORKSPACE/SOUL.md"
            curl -fsSL "https://raw.githubusercontent.com/ttracx/NellieOS/main/workspace/AGENTS.md" -o "$WORKSPACE/AGENTS.md"
            curl -fsSL "https://raw.githubusercontent.com/ttracx/NellieOS/main/workspace/USER.md" -o "$WORKSPACE/USER.md"
            curl -fsSL "https://raw.githubusercontent.com/ttracx/NellieOS/main/workspace/IDENTITY.md" -o "$WORKSPACE/IDENTITY.md"
            curl -fsSL "https://raw.githubusercontent.com/ttracx/NellieOS/main/workspace/HEARTBEAT.md" -o "$WORKSPACE/HEARTBEAT.md"
            curl -fsSL "https://raw.githubusercontent.com/ttracx/NellieOS/main/workspace/MEMORY.md" -o "$WORKSPACE/MEMORY.md"
        }
    fi
    
    # Copy config files to workspace if from repo
    if [ -d "$WORKSPACE/NellieOS/workspace" ]; then
        cp -r "$WORKSPACE/NellieOS/workspace/"* "$WORKSPACE/" 2>/dev/null || true
    fi
    
    log "Nellie configuration downloaded"
}

# Setup macOS-specific tools
setup_macos_tools() {
    info "Setting up macOS-specific tools..."
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        warn "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install useful tools
    brew install jq curl wget git 2>/dev/null || true
    
    # Check for iMessage/FaceTime CLI tools
    if [ -d "/Applications/Messages.app" ]; then
        log "Messages.app found - iMessage available"
    fi
    
    if [ -d "/Applications/FaceTime.app" ]; then
        log "FaceTime.app found"
    fi
    
    log "macOS tools configured"
}

# Create TOOLS.md for this machine
create_tools_md() {
    info "Creating machine-specific TOOLS.md..."
    
    HOSTNAME=$(hostname)
    OS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
    CHIP=$(uname -m)
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "not configured")
    
    cat > "$WORKSPACE/TOOLS.md" << EOF
# TOOLS.md - System Configuration

## Machine: $HOSTNAME

**OS:** macOS $OS_VERSION ($CHIP)
**Role:** NellieOS macOS Node (iMessage, FaceTime, media)
**User:** $(whoami)

## Network

| Service | Status | Address |
|---------|--------|---------|
| **Tailscale** | $(tailscale status &>/dev/null && echo "Connected" || echo "Not connected") | $TAILSCALE_IP |
| **KnightHub** | Primary | 100.120.210.28 |

## macOS Capabilities

| Feature | Status |
|---------|--------|
| **iMessage** | $([ -d "/Applications/Messages.app" ] && echo "✅ Available" || echo "❌ Not found") |
| **FaceTime** | $([ -d "/Applications/FaceTime.app" ] && echo "✅ Available" || echo "❌ Not found") |
| **AppleScript** | $(command -v osascript &>/dev/null && echo "✅ Available" || echo "❌ Not found") |

## OpenClaw Status

- **Workspace:** $WORKSPACE
- **Config:** ~/.openclaw/config.yaml
- **Node Role:** Satellite (reports to KnightHub)

## Notes

- This is a satellite node for macOS-specific features
- Primary processing happens on KnightHub (Linux/WSL2)
- Use for: iMessage, FaceTime, Apple-specific integrations
EOF
    
    log "TOOLS.md created for $HOSTNAME"
}

# Register with KnightHub inventory
register_device() {
    info "Registering device with KnightHub inventory..."
    
    HOSTNAME=$(hostname)
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "unknown")
    MAC_SERIAL=$(ioreg -l | grep IOPlatformSerialNumber | awk '{print $4}' | tr -d '"' 2>/dev/null || echo "unknown")
    
    DEVICE_INFO=$(cat << EOF
{
  "hostname": "$HOSTNAME",
  "type": "macos",
  "role": "nellieos-satellite",
  "tailscale_ip": "$TAILSCALE_IP",
  "serial": "$MAC_SERIAL",
  "capabilities": ["imessage", "facetime", "applescript", "media"],
  "provisioned_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "knighthub": "100.120.210.28"
}
EOF
)
    
    # Save device info locally
    echo "$DEVICE_INFO" > "$WORKSPACE/device-info.json"
    log "Device info saved to device-info.json"
    
    # Try to register with KnightHub (if reachable)
    if ping -c 1 100.120.210.28 &>/dev/null; then
        log "KnightHub reachable via Tailscale"
        # Could SSH and register, but for now just log
        info "Device ready to connect to KnightHub"
    else
        warn "KnightHub not reachable - ensure Tailscale is connected"
    fi
}

# Create startup script
create_startup() {
    info "Creating startup configuration..."
    
    # Create LaunchAgent for auto-start (optional)
    PLIST_PATH="$HOME/Library/LaunchAgents/com.neuralquantum.nellieos.plist"
    
    cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.neuralquantum.nellieos</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/node</string>
        <string>$(which openclaw)</string>
        <string>gateway</string>
        <string>start</string>
    </array>
    <key>RunAtLoad</key>
    <false/>
    <key>KeepAlive</key>
    <false/>
    <key>WorkingDirectory</key>
    <string>$WORKSPACE</string>
</dict>
</plist>
EOF
    
    log "LaunchAgent created (not auto-enabled)"
    info "To enable auto-start: launchctl load $PLIST_PATH"
}

# Main execution
main() {
    echo ""
    check_prerequisites
    setup_workspace
    download_nellie_config
    setup_macos_tools
    create_tools_md
    register_device
    create_startup
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║        NellieOS Provisioning Complete! ✓                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Next steps:"
    echo "  1. Configure OpenClaw: openclaw config"
    echo "  2. Start gateway: openclaw gateway start"
    echo "  3. Connect to KnightHub: Verify Tailscale connection"
    echo ""
    echo "Tailscale IP: $(tailscale ip -4 2>/dev/null || echo 'Run: tailscale up')"
    echo "KnightHub: 100.120.210.28"
    echo ""
}

main "$@"
