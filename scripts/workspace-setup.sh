#!/bin/bash
# ======================================================================
# Rxiv-Maker Workspace Setup Script
# ======================================================================
# Sets up an interactive terminal environment for working with rxiv-maker
# directly inside the Docker container.
# 
# NEW POLICY: rxiv-maker is pre-installed via UV during build time.
# No runtime installation needed.

set -e

echo "🚀 Setting up Rxiv-Maker workspace..."

# Verify rxiv-maker is available (should be pre-installed)
if ! command -v rxiv &> /dev/null; then
    echo "❌ ERROR: rxiv-maker not found! This should be pre-installed in the container."
    echo "🔧 This container uses the new policy where rxiv-maker is installed during build time."
    exit 1
fi

# Check if we're in a mounted workspace
if [[ -d "/workspace" && "$(ls -A /workspace 2>/dev/null)" ]]; then
    cd /workspace
    echo "📁 Working in mounted directory: /workspace"
    echo "📋 Contents:"
    ls -la
else
    # Create a default workspace structure
    mkdir -p /workspace/{manuscripts,output,templates}
    cd /workspace
    echo "📁 Created default workspace structure in /workspace"
    echo "📋 Workspace structure:"
    tree /workspace 2>/dev/null || ls -la
fi

# Show rxiv-maker status
echo ""
echo "✅ Rxiv-Maker ready!"
echo "📦 Pre-installed version: $(rxiv --version 2>/dev/null || echo 'version check failed')"
echo ""
echo "🔧 Available commands:"
echo "  • rxiv pdf [manuscript-dir]     - Generate PDF from manuscript"
echo "  • rxiv validate [manuscript-dir] - Validate manuscript structure"  
echo "  • rxiv --help                   - Show all available commands"
echo ""
echo "💡 Quick start examples:"
echo "  • rxiv pdf ./my-manuscript/"
echo "  • rxiv validate ./my-manuscript/"
echo "  • rxiv pdf . # (if current dir is manuscript)"
echo ""
echo "�� Ready for interactive work! Type 'rxiv --help' for more commands."
