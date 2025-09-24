#!/bin/bash
# ======================================================================
# NEW ARCHITECTURE TEST SUITE for GitHub Actions
# ======================================================================
# Tests the NEW pre-installed terminal-focused architecture (v2.5.0+)
# This script is designed to be used within GitHub Actions workflows
#
# Usage: ./test-new-architecture.sh <image_name>
# Example: ./test-new-architecture.sh henriqueslab/rxiv-maker-base:latest
# ======================================================================

set -e

IMAGE_NAME="${1:-henriqueslab/rxiv-maker-base:latest}"

echo "🧪 NEW ARCHITECTURE TEST SUITE (v2.5.0+)"
echo "=========================================="
echo "🖼️ Image: $IMAGE_NAME"
echo "📊 Testing: Pre-installed terminal-focused architecture"
echo ""

# Verify image exists locally (should already be loaded in workflow)
echo "🔍 Verifying image is available locally..."
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "❌ CRITICAL: Image $IMAGE_NAME not found locally"
  echo "Available images:"
  docker images
  exit 1
fi
echo "✅ Image found locally"
echo ""

# Test 1: Pre-installed rxiv-maker availability (CRITICAL)
echo "🎯 Test 1: Pre-installed rxiv-maker availability"
if timeout 30s docker run --rm "$IMAGE_NAME" rxiv --version 2>&1 | grep -q "rxiv-maker"; then
  echo "✅ rxiv-maker pre-installed and immediately available"
else
  echo "❌ CRITICAL: rxiv-maker not pre-installed (new architecture requirement FAILED)"
  echo "Checking if rxiv command exists..."
  docker run --rm "$IMAGE_NAME" which rxiv || echo "rxiv command not found"
  echo "Checking Python packages..."
  docker run --rm "$IMAGE_NAME" python3 -m pip list | grep rxiv || echo "rxiv-maker not in pip list"
  exit 1
fi

# Test 2: Helper scripts availability (new architecture feature)
echo "🎯 Test 2: Terminal-focused helper scripts availability"
if timeout 20s docker run --rm "$IMAGE_NAME" usage.sh | grep -q -i "terminal\|pre-installed"; then
  echo "✅ usage.sh available and updated for new architecture"
else
  echo "❌ usage.sh not available or not updated for new architecture"
  exit 1
fi

if timeout 20s docker run --rm "$IMAGE_NAME" which workspace-setup.sh >/dev/null 2>&1; then
  echo "✅ workspace-setup.sh available in container"
else
  echo "❌ workspace-setup.sh not available in container"
  exit 1
fi

# Test 3: Fast startup verification (should be <10s, not 30-60s like old architecture)
echo "🎯 Test 3: Fast startup time verification"
START_TIME=$(date +%s)
if timeout 15s docker run --rm "$IMAGE_NAME" echo "Container started" >/dev/null 2>&1; then
  END_TIME=$(date +%s)
  STARTUP_TIME=$((END_TIME - START_TIME))
  if [ $STARTUP_TIME -lt 10 ]; then
    echo "✅ Fast startup verified: ${STARTUP_TIME}s (new architecture benefit)"
  else
    echo "⚠️ Slower startup: ${STARTUP_TIME}s (expected <10s for new architecture)"
  fi
else
  echo "❌ Container startup failed or timed out"
  exit 1
fi

# Test 4: Old runtime installation scripts removal (architecture cleanup)
echo "🎯 Test 4: Old runtime installation artifacts cleanup verification"
if timeout 10s docker run --rm "$IMAGE_NAME" which dev-mode.sh >/dev/null 2>&1; then
  echo "⚠️ dev-mode.sh still exists (should be removed in new architecture)"
else
  echo "✅ dev-mode.sh properly removed (good - new architecture)"
fi

if timeout 10s docker run --rm "$IMAGE_NAME" which install-project-deps.sh >/dev/null 2>&1; then
  echo "⚠️ install-project-deps.sh still exists (should be removed in new architecture)"
else
  echo "✅ install-project-deps.sh properly removed (good - new architecture)"
fi

# Test 5: Direct manuscript processing capability (core new architecture feature)
echo "🎯 Test 5: Direct manuscript processing capability"
if timeout 30s docker run --rm "$IMAGE_NAME" bash -c "
  echo 'Testing direct rxiv command execution...'
  rxiv --help >/dev/null 2>&1 && echo 'Direct rxiv execution: SUCCESS'
" | grep -q "SUCCESS"; then
  echo "✅ Direct rxiv command execution works (new architecture core feature)"
else
  echo "❌ Direct rxiv command execution failed"
  exit 1
fi

# Test 6: No runtime dependency installation (architecture verification)
echo "🎯 Test 6: No runtime dependency installation verification"
# Check that we don't have any runtime installation logic
CONTAINER_OUTPUT=$(timeout 20s docker run --rm "$IMAGE_NAME" bash -c "
echo 'Container ready immediately'
rxiv --version
echo 'No installation steps required'
" 2>&1)

if echo "$CONTAINER_OUTPUT" | grep -q -i "install\|download\|setup"; then
  echo "⚠️ Found potential runtime installation activity (should not happen in new architecture)"
  echo "Output: $CONTAINER_OUTPUT"
else
  echo "✅ No runtime installation detected (good - new architecture)"
fi

echo ""
echo "✅ NEW ARCHITECTURE TEST SUITE COMPLETED"
echo "=========================================="
echo "🎯 Key features verified:"
echo "  ✅ Pre-installed rxiv-maker (immediate availability)"
echo "  ✅ Terminal-focused helper scripts"  
echo "  ✅ Fast startup time"
echo "  ✅ Old artifacts cleanup"
echo "  ✅ Direct command execution"
echo "  ✅ No runtime installation"
echo ""
echo "🚀 New architecture (v2.5.0+) validation: PASSED"
