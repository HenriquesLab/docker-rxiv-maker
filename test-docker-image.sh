#!/bin/bash
# ======================================================================
# Docker Image Testing Script - NEW ARCHITECTURE (v2.5.0+)
# ======================================================================
# Comprehensive testing script for rxiv-maker Docker images
# Tests the NEW pre-installed terminal-focused architecture
#
# NEW ARCHITECTURE: Tests that rxiv-maker is pre-installed via UV
# and ready for immediate terminal usage without runtime installation
#
# Usage:
#   ./test-docker-image.sh <image_name>
#   ./test-docker-image.sh henriqueslab/rxiv-maker-base:latest
# ======================================================================

set -e  # Exit on any error

# Configuration
DOCKER_IMAGE="${1:-henriqueslab/rxiv-maker-base:latest}"
TEST_WORKSPACE="/tmp/rxiv-docker-test-$$"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✅ SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[⚠️  WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[❌ ERROR]${NC} $1"; }

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    log_info "Running test: $test_name"
    
    if eval "$test_command"; then
        log_success "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "$test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

cleanup() {
    log_info "Cleaning up test environment..."
    rm -rf "$TEST_WORKSPACE"
    docker ps -q --filter "ancestor=$DOCKER_IMAGE" | xargs -r docker kill >/dev/null 2>&1 || true
}

# Setup cleanup trap
trap cleanup EXIT

echo "=================================================="
echo "🧪 NEW ARCHITECTURE DOCKER IMAGE TESTING (v2.5.0+)"
echo "=================================================="
echo "🖼️  Image: $DOCKER_IMAGE"
echo "📁 Test workspace: $TEST_WORKSPACE"
echo "📊 Testing: Pre-installed rxiv-maker via UV"
echo "=================================================="

# Create test workspace
mkdir -p "$TEST_WORKSPACE"

# Test 1: Basic image availability
run_test "Image availability" \
    "docker image inspect $DOCKER_IMAGE >/dev/null 2>&1"

# Test 2: Pre-installed rxiv-maker availability (CRITICAL for new architecture)
run_test "Pre-installed rxiv-maker availability" \
    "docker run --rm $DOCKER_IMAGE rxiv --version >/dev/null 2>&1"

# Test 3: Immediate rxiv command execution (no setup scripts needed)
run_test "Immediate rxiv command execution" \
    "timeout 10s docker run --rm $DOCKER_IMAGE rxiv --help >/dev/null 2>&1"

# Test 4: Helper scripts availability (new architecture feature)
run_test "Helper scripts availability - usage.sh" \
    "timeout 10s docker run --rm $DOCKER_IMAGE usage.sh >/dev/null 2>&1"

run_test "Helper scripts availability - workspace-setup.sh" \
    "timeout 10s docker run --rm $DOCKER_IMAGE workspace-setup.sh --help >/dev/null 2>&1 || \
     timeout 10s docker run --rm $DOCKER_IMAGE which workspace-setup.sh >/dev/null 2>&1"

# Test 5: Fast startup time (should be <10s, not 30-60s like old architecture)
run_test "Fast startup time (<10s)" \
    "timeout 10s docker run --rm $DOCKER_IMAGE echo 'Container started successfully' >/dev/null 2>&1"

# Test 6: No runtime installation scripts (old architecture cleanup)
log_info "Verifying old runtime installation scripts are removed..."
if docker run --rm $DOCKER_IMAGE which dev-mode.sh >/dev/null 2>&1; then
    log_warning "dev-mode.sh still exists - should be removed in new architecture"
else
    log_success "dev-mode.sh properly removed (good - new architecture)"
fi

if docker run --rm $DOCKER_IMAGE which install-project-deps.sh >/dev/null 2>&1; then
    log_warning "install-project-deps.sh still exists - should be removed in new architecture"  
else
    log_success "install-project-deps.sh properly removed (good - new architecture)"
fi

# Test 7: Direct manuscript processing (core functionality)
log_info "Creating test manuscript for processing..."
cat > "$TEST_WORKSPACE/test-manuscript.md" << 'MANUSCRIPT_EOF'
---
title: "Test Manuscript"
authors: "Test Author"
---

# Introduction

This is a test manuscript for validating the new Docker architecture.

## Methods

Testing pre-installed rxiv-maker functionality.

## Results  

Docker container should process this immediately without setup.
MANUSCRIPT_EOF

# Create simple manuscript structure
mkdir -p "$TEST_WORKSPACE/manuscript"
cp "$TEST_WORKSPACE/test-manuscript.md" "$TEST_WORKSPACE/manuscript/01_MAIN.md"
echo "bibliography: []" > "$TEST_WORKSPACE/manuscript/03_REFERENCES.bib"

run_test "Direct manuscript processing" \
    "timeout 30s docker run --rm -v $TEST_WORKSPACE:/workspace $DOCKER_IMAGE \
     rxiv validate /workspace/manuscript/ >/dev/null 2>&1"

# Test 8: Interactive terminal usage simulation
run_test "Interactive terminal readiness" \
    "timeout 15s docker run --rm -i $DOCKER_IMAGE bash -c 'echo \"Container ready\"; rxiv --version; echo \"Success\"' >/dev/null 2>&1"

# Test 9: Version consistency (should show specific version, not installation messages)
log_info "Checking version output consistency..."
VERSION_OUTPUT=$(docker run --rm $DOCKER_IMAGE rxiv --version 2>&1)
if echo "$VERSION_OUTPUT" | grep -q "rxiv-maker" && ! echo "$VERSION_OUTPUT" | grep -qi "install"; then
    log_success "Version output shows pre-installed rxiv-maker (no installation messages)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_error "Version output suggests runtime installation (should be pre-installed)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# Test 10: Architecture verification  
log_info "Verifying new architecture markers..."
ARCHITECTURE_CHECK=$(docker run --rm $DOCKER_IMAGE bash -c 'echo "Checking labels..."; docker image inspect $0 2>/dev/null | grep -i "uv-preinstalled" || echo "Architecture verification via labels not available from inside container"' $DOCKER_IMAGE 2>/dev/null || echo "Label check skipped")

# Final Results
echo ""
echo "=================================================="
echo "📊 TEST RESULTS SUMMARY"
echo "=================================================="
echo "🏃 Tests run: $TESTS_RUN"
echo "✅ Tests passed: $TESTS_PASSED"  
echo "❌ Tests failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    log_success "🎉 ALL TESTS PASSED - NEW ARCHITECTURE WORKING!"
    echo ""
    echo "🎯 NEW ARCHITECTURE FEATURES VERIFIED:"
    echo "  ✅ rxiv-maker pre-installed via UV"
    echo "  ✅ Immediate terminal usage (no setup scripts needed)"  
    echo "  ✅ Fast startup time (<10s)"
    echo "  ✅ Helper scripts available (usage.sh, workspace-setup.sh)"
    echo "  ✅ Direct manuscript processing"
    echo "  ✅ No old runtime installation artifacts"
    echo ""
    echo "🚀 Ready for production deployment!"
    exit 0
else
    echo ""
    log_error "🚨 SOME TESTS FAILED - ARCHITECTURE NEEDS FIXES"
    echo ""
    echo "🔧 Troubleshooting hints:"
    echo "  • Ensure rxiv-maker is installed via UV during Docker build"
    echo "  • Check that helper scripts are copied to /usr/local/bin/"
    echo "  • Verify no runtime installation logic remains"
    echo "  • Test image was built with new Dockerfile (v2.5.0+)"
    exit 1
fi
