# iMessage Setup Guide for Nellie Ross

This guide configures the macOS device (100.120.210.28) to allow Nellie to send and receive iMessages.

## Overview

**Architecture:**
```
OpenClaw (KnightHub) ←→ BlueBubbles Server (Mac) ←→ iMessage
```

**Components:**
- **BlueBubbles Server** - REST API for iMessage (runs on Mac)
- **OpenClaw BlueBubbles Channel** - Connects to BlueBubbles API
- **AppleScript** (fallback) - Direct message sending via script

---

## Option 1: BlueBubbles (Recommended)

BlueBubbles provides a full REST API for iMessage with webhooks for incoming messages.

### Step 1: Download BlueBubbles Server

```bash
# On the Mac (100.120.210.28)
# Download from: https://bluebubbles.app/downloads/

# Or via Homebrew Cask
brew install --cask bluebubbles
```

### Step 2: Configure BlueBubbles Server

1. **Launch BlueBubbles Server**
2. **Grant Permissions:**
   - Full Disk Access (System Preferences → Security & Privacy → Privacy → Full Disk Access)
   - Accessibility (for sending messages)
   - Automation (for Messages.app control)

3. **Configure Server Settings:**
   - **Server URL:** Use Tailscale IP (100.120.210.28)
   - **Port:** 1234 (default)
   - **Password:** Generate a secure password

4. **Enable Webhooks:**
   - Add webhook URL: `http://100.120.210.28:3000/webhook/bluebubbles`
   - This allows OpenClaw to receive incoming messages

### Step 3: Test API Access

```bash
# From KnightHub, test the connection
curl -X GET "http://100.120.210.28:1234/api/v1/server/info" \
  -H "Authorization: Bearer YOUR_PASSWORD"
```

### Step 4: Configure OpenClaw BlueBubbles Channel

Add to OpenClaw config (`~/.openclaw/config.yaml`):

```yaml
channels:
  bluebubbles:
    enabled: true
    serverUrl: "http://100.120.210.28:1234"
    password: "YOUR_BLUEBUBBLES_PASSWORD"
    webhookPort: 3000
    defaultHandle: "+15127911976"  # Nellie's number
```

### Step 5: Test Messaging

```bash
# Send a test message via OpenClaw
openclaw message send --channel bluebubbles --to "+19012759068" --message "Hello from Nellie!"
```

---

## Option 2: AppleScript Direct Control

For simple send-only functionality without BlueBubbles.

### Setup Script

Create `~/send-imessage.scpt` on the Mac:

```applescript
on run argv
    set targetBuddy to item 1 of argv
    set targetMessage to item 2 of argv
    
    tell application "Messages"
        set targetService to 1st service whose service type = iMessage
        set targetBuddy to buddy targetBuddy of targetService
        send targetMessage to targetBuddy
    end tell
end run
```

### Usage via SSH

```bash
# From KnightHub
ssh mac@100.120.210.28 'osascript ~/send-imessage.scpt "+19012759068" "Hello from Nellie!"'
```

### Create Helper Script

On the Mac, create `~/imessage-send.sh`:

```bash
#!/bin/bash
# Usage: ./imessage-send.sh "+1234567890" "Your message here"

TO="$1"
MESSAGE="$2"

osascript -e "tell application \"Messages\"
    set targetService to 1st service whose service type = iMessage
    set targetBuddy to buddy \"$TO\" of targetService
    send \"$MESSAGE\" to targetBuddy
end tell"
```

Make executable:
```bash
chmod +x ~/imessage-send.sh
```

---

## Option 3: OpenClaw Node Integration

Configure the Mac as an OpenClaw node for direct message control.

### Step 1: Pair the Mac Node

On the Mac:
```bash
# Install OpenClaw
npm install -g openclaw

# Start in node mode
openclaw node start --pair
```

On KnightHub:
```bash
# Approve the pending node
openclaw nodes approve macos-nellie-1
```

### Step 2: Use Node Message Commands

```bash
# Send message via node
openclaw nodes run --node macos-nellie-1 --command "osascript -e 'tell application \"Messages\" to send \"Hello!\" to buddy \"+19012759068\" of (1st service whose service type = iMessage)'"
```

---

## Permissions Required (macOS)

System Preferences → Security & Privacy → Privacy:

| Permission | Required For |
|------------|--------------|
| **Full Disk Access** | Access Messages database |
| **Accessibility** | Send keystrokes/control Messages.app |
| **Automation → Messages** | AppleScript control |

### Grant via Terminal (if needed)

```bash
# Open Privacy settings
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
```

---

## Testing Checklist

- [ ] BlueBubbles Server running on Mac
- [ ] API accessible from KnightHub: `curl http://100.120.210.28:1234/api/v1/server/info`
- [ ] Permissions granted (Full Disk Access, Accessibility, Automation)
- [ ] Test send via API works
- [ ] Test receive via webhook works
- [ ] OpenClaw channel configured

---

## Troubleshooting

### "Messages.app not responding"
```bash
# Restart Messages.app
killall Messages
open -a Messages
```

### "Permission denied"
- Ensure Full Disk Access is granted to BlueBubbles/Terminal
- Restart the Mac after granting permissions

### "Network unreachable"
- Verify Tailscale is connected: `tailscale status`
- Ping test: `ping 100.120.210.28`

### "API returns 401"
- Check BlueBubbles password matches config
- Regenerate password in BlueBubbles settings

---

## Quick Setup Commands (Copy-Paste)

Run these on the Mac (100.120.210.28):

```bash
# 1. Install BlueBubbles
brew install --cask bluebubbles

# 2. Create AppleScript helper
cat > ~/imessage-send.sh << 'EOF'
#!/bin/bash
TO="$1"
MESSAGE="$2"
osascript -e "tell application \"Messages\"
    set targetService to 1st service whose service type = iMessage
    set targetBuddy to buddy \"$TO\" of targetService
    send \"$MESSAGE\" to targetBuddy
end tell"
EOF
chmod +x ~/imessage-send.sh

# 3. Test send (replace number)
~/imessage-send.sh "+19012759068" "Test from Nellie setup"
```

---

## Integration with Nellie

Once configured, Nellie can:
- **Send iMessages** via BlueBubbles API or AppleScript
- **Receive iMessages** via BlueBubbles webhooks
- **Read message history** via Messages database
- **Send group messages** via iMessage groups
- **Share media** (photos, videos, files)

**Default Handle:** +1 (512) 791-1976 (nellie@vibecaas.com)
