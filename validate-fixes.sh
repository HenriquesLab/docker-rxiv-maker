#!/bin/bash
# ======================================================================
# Validation Script for Docker-Rxiv-Maker Fixes
# ======================================================================
# This script validates that all critical fixes are in place and working
# Run this before pushing to verify everything is correct
# ======================================================================

set -e

echo "🔍 DOCKER-RXIV-MAKER FIXES VALIDATION"
echo "======================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
PASSED=0
FAILED=0
WARNINGS=0

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✅${NC} File exists: $1"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}❌${NC} File missing: $1"
        FAILED=$((FAILED + 1))
    fi
}

# Function to check file contains pattern
check_pattern() {
    if grep -q "$2" "$1"; then
        echo -e "${GREEN}✅${NC} Pattern found in $1: $2"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}❌${NC} Pattern NOT found in $1: $2"
        FAILED=$((FAILED + 1))
    fi
}

# Function to check file does NOT contain pattern
check_not_pattern() {
    if ! grep -q "$2" "$1"; then
        echo -e "${GREEN}✅${NC} Pattern correctly absent from $1: $2"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}❌${NC} Pattern should NOT be in $1: $2"
        FAILED=$((FAILED + 1))
    fi
}

echo "📋 Checking Critical Files..."
echo "------------------------------"
check_file ".github/workflows/docker-build.yml"
check_file ".github/workflows/build-weekly.yml"
check_file ".github/workflows/build-release.yml"
check_file ".github/workflows/build-on-demand.yml"
check_file ".github/workflows/test-new-architecture.sh"
check_file "images/base/Dockerfile"
check_file "scripts/workspace-setup.sh"
check_file "scripts/usage.sh"
echo ""

echo "🔧 Validating Workflow Fixes..."
echo "--------------------------------"

# Check docker-build.yml has correct image tag detection
check_pattern ".github/workflows/docker-build.yml" "LOADED_IMAGE_TAG=\$(docker images"
check_pattern ".github/workflows/docker-build.yml" "test-new-architecture.sh \"\$LOADED_IMAGE_TAG\""

# Check weekly workflow
check_pattern ".github/workflows/build-weekly.yml" "LOADED_IMAGE_TAG=\$(docker images"

# Check release workflow
check_pattern ".github/workflows/build-release.yml" "LOADED_IMAGE_TAG=\$(docker images"

# Check on-demand workflow
check_pattern ".github/workflows/build-on-demand.yml" "LOADED_IMAGE_TAG=\$(docker images"

echo ""

echo "🧪 Validating Test Script..."
echo "----------------------------"

# Check test script has local image verification
check_pattern ".github/workflows/test-new-architecture.sh" "docker image inspect"
check_pattern ".github/workflows/test-new-architecture.sh" "Image found locally"

# Check test script is executable
if [ -x ".github/workflows/test-new-architecture.sh" ]; then
    echo -e "${GREEN}✅${NC} test-new-architecture.sh is executable"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}❌${NC} test-new-architecture.sh is NOT executable"
    FAILED=$((FAILED + 1))
fi

echo ""

echo "🐳 Validating Dockerfile..."
echo "---------------------------"

# Check Dockerfile has correct COPY paths
check_pattern "images/base/Dockerfile" "COPY scripts/workspace-setup.sh"
check_pattern "images/base/Dockerfile" "COPY scripts/usage.sh"

# Check Dockerfile does NOT have incorrect paths
check_not_pattern "images/base/Dockerfile" "COPY \.\./\.\./scripts"

# Check Dockerfile has correct labels
check_pattern "images/base/Dockerfile" "org.opencontainers.image.source=.*docker-rxiv-maker"
check_pattern "images/base/Dockerfile" "org.opencontainers.image.description=.*pre-installed via UV"

# Check old APT reference is removed
check_not_pattern "images/base/Dockerfile" "from APT repository"

# Check UV installation is present
check_pattern "images/base/Dockerfile" "uv pip install --system rxiv-maker"

echo ""

echo "📚 Validating Documentation..."
echo "-------------------------------"

# Check README has recent updates
check_pattern "README.md" "September 24, 2025"
check_pattern "README.md" "Fixed all GitHub Actions workflows"

# Check CLAUDE.md has fix documentation
check_pattern "CLAUDE.md" "Recent Fixes"
check_pattern "CLAUDE.md" "Critical GitHub Actions Fixes"

echo ""

echo "🔐 Checking Git Status..."
echo "-------------------------"

# Check if there are uncommitted changes
if [ -z "$(git status --porcelain)" ]; then
    echo -e "${GREEN}✅${NC} No uncommitted changes - ready to push"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠️${NC}  Uncommitted changes found:"
    git status --short
    WARNINGS=$((WARNINGS + 1))
fi

# Check if ahead of origin
AHEAD=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo "0")
if [ "$AHEAD" -gt 0 ]; then
    echo -e "${YELLOW}⚠️${NC}  Local branch is $AHEAD commit(s) ahead of origin/main"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅${NC} Branch is up to date with origin"
    PASSED=$((PASSED + 1))
fi

echo ""

echo "📊 VALIDATION SUMMARY"
echo "====================="
echo ""
echo -e "✅ Passed:   ${GREEN}$PASSED${NC}"
echo -e "❌ Failed:   ${RED}$FAILED${NC}"
echo -e "⚠️  Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All validations passed!${NC}"
    echo ""
    echo "✅ Repository is ready:"
    echo "   1. All critical fixes are in place"
    echo "   2. Workflows should pass on next run"
    echo "   3. Architecture v2.5.0 is correctly implemented"
    echo ""
    echo "📤 Next steps:"
    echo "   1. git push origin main"
    echo "   2. Monitor GitHub Actions workflow run"
    echo "   3. Verify successful build and test"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Validation failed!${NC}"
    echo ""
    echo "Please fix the $FAILED failed check(s) above before pushing."
    echo ""
    exit 1
fi