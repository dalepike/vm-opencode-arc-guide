#!/bin/bash
set -e

# Pass through info flags directly (no auth needed)
case "$1" in
  --version|-v|--help|-h)
    exec /root/.opencode/bin/opencode "$@"
    ;;
esac

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║  OpenCode + VT ARC                              ║"
echo "║  AI coding assistant on Virginia Tech's network  ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# Check if API key is already set (via .env or -e flag)
if [ -z "$VT_ARC_API_KEY" ] || [ "$VT_ARC_API_KEY" = "sk-your-key-here" ]; then
  echo "No API key found."
  echo ""
  echo "Get yours at: https://llm.arc.vt.edu/"
  echo "  Profile -> Settings -> Account -> API Keys"
  echo ""
  read -rp "Paste your VT ARC API key: " VT_ARC_API_KEY
  export VT_ARC_API_KEY
  echo ""

  if [ -z "$VT_ARC_API_KEY" ]; then
    echo "Error: API key is required."
    exit 1
  fi
fi

# Quick connectivity check
echo "Testing connection to VT ARC..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $VT_ARC_API_KEY" \
  https://llm-api.arc.vt.edu/api/v1/models 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
  echo "Connected. Launching OpenCode..."
  echo ""
elif [ "$HTTP_CODE" = "401" ]; then
  echo "Error: Invalid API key. Check your key at https://llm.arc.vt.edu/"
  exit 1
elif [ "$HTTP_CODE" = "000" ]; then
  echo "Warning: Cannot reach VT ARC. Are you on campus or connected to VPN?"
  echo "Launching OpenCode anyway (it will retry on its own)..."
  echo ""
else
  echo "Warning: Unexpected response ($HTTP_CODE). Launching anyway..."
  echo ""
fi

exec /root/.opencode/bin/opencode "$@"
