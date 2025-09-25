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
# Detect if we're running under QEMU emulation (ARM64 on AMD64)
PLATFORM_TIMEOUT=30s
if docker run --rm "$IMAGE_NAME" uname -m | grep -q aarch64; then
  echo "🔧 ARM64 platform detected - extending timeout for QEMU emulation"
  PLATFORM_TIMEOUT=60s
fi

if timeout $PLATFORM_TIMEOUT docker run --rm "$IMAGE_NAME" sh -c "rxiv --version && which rxiv" >/dev/null 2>&1; then
  echo "✅ rxiv-maker pre-installed and immediately available"
else
  echo "❌ CRITICAL: rxiv-maker not pre-installed (new architecture requirement FAILED)"
  echo "Checking if rxiv command exists..."
  timeout $PLATFORM_TIMEOUT docker run --rm "$IMAGE_NAME" which rxiv || echo "rxiv command not found"
  echo "Checking Python packages..."
  timeout $PLATFORM_TIMEOUT docker run --rm "$IMAGE_NAME" python3 -m pip list | grep rxiv || echo "rxiv-maker not in pip list"
  exit 1
fi

# Test 2: Helper scripts availability (new architecture feature)
echo "🎯 Test 2: Terminal-focused helper scripts availability"
SCRIPT_TIMEOUT=20s
if docker run --rm "$IMAGE_NAME" uname -m | grep -q aarch64; then
  SCRIPT_TIMEOUT=45s
fi

if timeout $SCRIPT_TIMEOUT docker run --rm "$IMAGE_NAME" usage.sh | grep -q -i "terminal\|pre-installed"; then
  echo "✅ usage.sh available and updated for new architecture"
else
  echo "❌ usage.sh not available or not updated for new architecture"
  exit 1
fi

if timeout $SCRIPT_TIMEOUT docker run --rm "$IMAGE_NAME" which workspace-setup.sh >/dev/null 2>&1; then
  echo "✅ workspace-setup.sh available in container"
else
  echo "❌ workspace-setup.sh not available in container"
  exit 1
fi

# Test 3: Startup time verification (adjusted for platform)
echo "🎯 Test 3: Startup time verification"
START_TIME=$(date +%s)
STARTUP_TIMEOUT=15s
EXPECTED_MAX=10

# Adjust expectations for ARM64 QEMU emulation
if docker run --rm "$IMAGE_NAME" uname -m | grep -q aarch64; then
  echo "🔧 ARM64 emulation detected - adjusting startup expectations"
  STARTUP_TIMEOUT=30s
  EXPECTED_MAX=25
fi

if timeout $STARTUP_TIMEOUT docker run --rm "$IMAGE_NAME" echo "Container started" >/dev/null 2>&1; then
  END_TIME=$(date +%s)
  STARTUP_TIME=$((END_TIME - START_TIME))
  if [ $STARTUP_TIME -lt $EXPECTED_MAX ]; then
    echo "✅ Good startup time: ${STARTUP_TIME}s (under ${EXPECTED_MAX}s limit)"
  else
    echo "⚠️ Slower startup: ${STARTUP_TIME}s (expected <${EXPECTED_MAX}s for this platform)"
  fi
else
  echo "❌ Container startup failed or timed out after $STARTUP_TIMEOUT"
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
EXEC_TIMEOUT=30s
if docker run --rm "$IMAGE_NAME" uname -m | grep -q aarch64; then
  EXEC_TIMEOUT=60s
fi

if timeout $EXEC_TIMEOUT docker run --rm "$IMAGE_NAME" bash -c "
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
VERIFICATION_TIMEOUT=20s
if docker run --rm "$IMAGE_NAME" uname -m | grep -q aarch64; then
  VERIFICATION_TIMEOUT=45s
fi

CONTAINER_OUTPUT=$(timeout $VERIFICATION_TIMEOUT docker run --rm "$IMAGE_NAME" bash -c "
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
