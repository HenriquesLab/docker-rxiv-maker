# Docker Infrastructure for Rxiv-Maker

Docker image building infrastructure for rxiv-maker with weekly and on-demand builds.

## Overview

This repository contains the Docker image building infrastructure for rxiv-maker, separated from the main repository to enable independent build schedules and better CI/CD management. All images use the mermaid.ink API for diagram generation, eliminating browser dependencies.

## Build Schedule

- **Weekly Builds**: Every Monday at 2 AM UTC with latest dependency updates
- **On-Demand Builds**: Manual workflow dispatch for testing and hotfixes  
- **Release Builds**: Triggered by main rxiv-maker releases with version tags

## Repository Structure

```
docker-rxiv-maker/
├── .github/
│   ├── workflows/
│   │   ├── build-weekly.yml      # Weekly scheduled builds
│   │   ├── build-on-demand.yml   # Manual trigger builds
│   │   └── build-release.yml     # Release-triggered builds
│   └── scripts/
│       └── builder.py            # Docker build automation
├── images/
│   └── base/                     # Base Docker images
│       ├── Dockerfile            # Main production Dockerfile
│       ├── build.sh              # Build script
│       └── Makefile              # Management commands
├── docs/                         # Documentation
├── scripts/                      # Build utilities
└── tests/                        # Build verification tests
```

## Image Details

### Base Images (`images/base/`)
- **Repository**: `henriqueslab/rxiv-maker-base`
- **Tags**: `latest`, `v1.x`
- **Architecture**: AMD64, ARM64 (native performance)
- **Purpose**: Production-ready images with complete LaTeX, Python, Node.js, and R environments
- **Features**: Mermaid.ink API integration, no browser dependencies, optimized image size

## Quick Start

### Development Mode (Recommended)

The new **runtime dependency injection** approach provides perfect dependency synchronization:

```bash
# Development mode: Auto-install latest dependencies from pyproject.toml
docker run -it --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest dev-mode.sh

# Manual dependency installation
docker run --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest install-project-deps.sh

# View all usage options
docker run --rm henriqueslab/rxiv-maker-base:latest usage.sh
```

### Production Mode

```bash
# Use pre-installed base dependencies (stable but may have version drift)
docker run -it --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest
```

### Building Images Locally

```bash
# Build base image locally
cd images/base
./build.sh --local

# Build and push to Docker Hub (requires login)
./build.sh --tag latest --push
```

## Image Contents

Base images include:
- **Ubuntu 22.04** LTS base
- **Complete LaTeX distribution** (texlive-full)
- **Python 3.11** with scientific libraries (NumPy, Matplotlib, etc.)
- **Node.js 18 LTS** (no mermaid-cli needed)
- **R base** with common packages and graphics support
- **SVG processing libraries**
- **Extended font collection** for better rendering
- **System dependencies** for graphics and multimedia processing

## Runtime Dependency Injection

### Overview

The Docker images now support **runtime dependency injection**, eliminating dependency drift between `pyproject.toml` and Docker images:

- **Development Mode**: Dependencies installed at runtime from `pyproject.toml`
- **Production Mode**: Pre-installed dependencies for stability
- **Perfect Sync**: No more version mismatches or missing packages

### Available Scripts

The base image includes several convenience scripts:

| Script | Purpose | Usage |
|--------|---------|-------|
| `dev-mode.sh` | Development mode with auto-setup | Interactive development |
| `install-project-deps.sh` | Install dependencies from pyproject.toml | CI/automation |
| `usage.sh` | Show usage instructions | Help and documentation |
| `verify-python-deps.sh` | Verify base dependencies | Troubleshooting |

### Development Workflow

```bash
# 1. Start development mode
docker run -it --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest dev-mode.sh

# 2. Dependencies are automatically installed from your pyproject.toml
# 3. Start coding with perfect dependency sync!
```

## Usage with Rxiv-Maker

### Standalone Docker Execution
```bash
# Run rxiv-maker commands directly in Docker container
docker run -it --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest rxiv pdf

# Interactive development mode with dependency sync
docker run -it --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest dev-mode.sh

# Batch processing mode
docker run --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest rxiv pdf MANUSCRIPT/
```

### Manual Docker Usage

**Development Mode (Recommended):**
```bash
# Interactive development with dependency sync
docker run -it --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest dev-mode.sh

# One-time dependency installation then run commands
docker run --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest install-project-deps.sh
docker run --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest rxiv pdf
```

**Production Mode:**
```bash
# Use pre-installed dependencies for direct execution
docker run -it --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest
# Inside container: rxiv pdf, rxiv validate, etc.
```

## Development

### Building Images

```bash
# Build and test locally
cd images/base
make image-build

# Build and push to Docker Hub (requires Docker Hub login)
make image-push

# Build specific version
make image-version VERSION=v1.2.3
```

### Testing Images

```bash
# Test image functionality
make image-test

# Check build status
make build-status
```

## Benefits of Runtime Dependency Injection

### Development Benefits
- **Perfect Sync**: Dependencies always match your `pyproject.toml`
- **No Version Drift**: Eliminates the need to rebuild images for dependency changes
- **Fast Iteration**: Immediate dependency updates without image rebuilds
- **Consistent Environment**: Same dependencies locally and in containers

### CI/CD Benefits
- **Reliable Builds**: No more "works locally but fails in Docker" issues
- **Reduced Maintenance**: Base image rarely needs updates
- **Faster Feedback**: Dependency issues caught early in validation

## Performance

Docker images provide significant performance improvements:

| Mode | Environment | Build Time | Dependency Install | Total Time | Benefits |
|------|-------------|------------|-------------------|------------|----------|
| Traditional | Local Install | 8-15 min | 5-10 min | 15-25 min | Full control |
| Traditional | Docker Image | 2-3 min | Pre-installed | 2-3 min | Fast but drift-prone |
| **New Approach** | **Runtime Injection** | **2-3 min** | **1-2 min** | **3-5 min** | **Fast + Perfect Sync** |

### Performance Notes
- **Base image pull**: ~2-3 minutes (cached after first pull)
- **Runtime dependency install**: ~1-2 minutes (faster with UV)
- **Total overhead**: ~3-5 minutes vs 15-25 minutes local install
- **Perfect reliability**: No dependency drift issues

## Integration with GitHub Actions

### Automated Testing

The `container-engines.yml` workflow now includes comprehensive dependency validation:

1. **Base Dependency Tests**: Validates essential packages are available
2. **Runtime Injection Tests**: Tests the new dependency injection approach  
3. **Import Validation**: Verifies critical rxiv-maker modules can be imported
4. **Multi-Engine Support**: Tests both Docker and Podman engines

### Image Building

Images are now built in this dedicated repository using specialized workflows:

#### Weekly Build (`build-weekly.yml`)
- **Schedule**: `0 2 * * 1` (Monday 2 AM UTC)
- **Purpose**: Keep images fresh with latest dependency updates
- **Output**: Tagged with `:weekly` and date stamps
- **Features**: Full dependency refresh, security updates

#### On-Demand Build (`build-on-demand.yml`)
- **Trigger**: Manual workflow dispatch
- **Purpose**: Testing, hotfixes, custom builds
- **Parameters**: Custom tags, build options
- **Features**: Flexible configuration, push options

#### Release Build (`build-release.yml`)
- **Trigger**: Webhook from main repository releases
- **Purpose**: Version-specific images for releases  
- **Output**: Tagged with version numbers, `:latest` for stable
- **Features**: Synchronized with main repo versions

## Integration with Main Repository

The main rxiv-maker repository has migrated to a local-only architecture. Users who need Docker functionality should use this repository directly instead of the deprecated engine system. This provides:

- **Cleaner Architecture**: Main repo focuses on local execution while this repo handles containerized workflows
- **Better Reliability**: Stable, tested images available on schedule
- **Independent Updates**: Docker dependencies can update without affecting main repo releases  
- **Resource Efficiency**: Dedicated CI resources for image building and Docker-specific features

## Migration Benefits

This repository provides the complete Docker solution for rxiv-maker after the deprecation of container engines in the main repository. This architecture provides:

- **Cleaner Separation**: Main repo focuses on local execution, this repo handles all containerized workflows
- **Specialized Infrastructure**: Docker-optimized workflows, caching, and CI/CD pipelines
- **Independent Development**: Images and Docker features can evolve independently
- **Complete Docker Solution**: All container-related functionality in one dedicated repository

## License

MIT License - see main repository LICENSE file for details.