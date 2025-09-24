# Docker Infrastructure for Rxiv-Maker

Docker image building infrastructure for rxiv-maker with **pre-installed rxiv-maker via UV** for direct terminal usage.

## 🆕 NEW POLICY: Pre-installed Terminal-Focused Architecture

**MAJOR CHANGE**: We have shifted from runtime dependency injection to **pre-installed rxiv-maker** during Docker build time.

### Key Changes:
- ✅ **rxiv-maker pre-installed via UV** during Docker build
- ✅ **Direct terminal usage** - no runtime installation needed
- ✅ **Faster startup** - immediate rxiv-maker availability
- ✅ **Consistent versions** - locked at build time
- ❌ **No more runtime dependency injection** (old approach deprecated)

## Build Schedule

- **Weekly Builds**: Every Monday at 2 AM UTC with latest rxiv-maker version
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
│       ├── Dockerfile            # NEW: UV pre-installation Dockerfile
│       ├── build.sh              # Build script
│       └── Makefile              # Management commands
├── scripts/                      # NEW: Terminal-focused helper scripts
│   ├── workspace-setup.sh        # Interactive workspace setup
│   └── usage.sh                  # Usage instructions
├── docs/                         # Documentation
└── tests/                        # Build verification tests
```

## Image Details

### Base Images (`images/base/`)
- **Repository**: `henriqueslab/rxiv-maker-base`
- **Tags**: `latest`, `v2.5.x` (new versioning for UV-based images)
- **Architecture**: AMD64, ARM64 (native performance)
- **Purpose**: Production-ready images with **pre-installed rxiv-maker via UV**
- **Features**: 
  - ✅ rxiv-maker ready for immediate use
  - ✅ Complete LaTeX distribution (TeX Live)
  - ✅ Python 3.11 with scientific libraries
  - ✅ R with graphics packages  
  - ✅ Mermaid.ink API integration
  - ✅ No browser dependencies
  - ✅ Optimized image size

## 🚀 Quick Start (NEW TERMINAL-FOCUSED WORKFLOW)

### Interactive Terminal Usage (Recommended)

**NEW**: Start an interactive terminal session and use rxiv-maker directly:

```bash
# Start interactive container with your manuscript
docker run -it --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest

# Inside container: Use rxiv-maker directly (pre-installed!)
rxiv pdf ./my-manuscript/
rxiv validate ./my-manuscript/  
rxiv --help

# Optional: Set up workspace structure  
workspace-setup.sh
```

### Direct Command Execution

**NEW**: Run rxiv-maker commands directly without interactive shell:

```bash
# Generate PDF (one command)
docker run --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest rxiv pdf .

# Validate manuscript (one command)  
docker run --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest rxiv validate .

# View usage instructions
docker run --rm henriqueslab/rxiv-maker-base:latest usage.sh
```

### Helper Scripts (Available in Container)

```bash
# Inside container - helper scripts available globally:
usage.sh                 # Usage instructions
workspace-setup.sh       # Interactive workspace setup
rxiv --version           # Check pre-installed version
```

## 🔄 Migration from Old Architecture

If you were using the old "runtime dependency injection" approach:

### OLD (Deprecated):
```bash
# OLD: Runtime dependency injection approach
docker run -it --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest dev-mode.sh
docker run --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest install-project-deps.sh
```

### NEW (Current):
```bash  
# NEW: Direct terminal usage (rxiv-maker pre-installed)
docker run -it --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest
# Then inside container: rxiv pdf ./my-manuscript/
```

## Benefits of New Architecture

| Aspect | OLD (Runtime Injection) | NEW (Pre-installed) |
|--------|------------------------|-------------------|
| **Startup Time** | ~30-60s (dependency installation) | ~2-3s (immediate) |
| **Reliability** | Depends on PyPI availability | Pre-built, always works |
| **Version Consistency** | Runtime variations possible | Locked at build time |
| **Offline Usage** | Requires internet for first run | Works completely offline |
| **Usage Complexity** | Requires setup scripts | Direct rxiv commands |

## Docker Image Building

### Local Development
```bash
# Build new UV-based image locally
cd images/base
./build.sh                      # Build for local development
./build.sh --push              # Build and push to registry
```

### Build Configuration
- Uses **UV for rxiv-maker installation** during build time
- Includes terminal-focused helper scripts
- Optimized for immediate terminal usage
- No runtime dependency installation needed

## Troubleshooting

### Common Issues

**Problem**: "rxiv command not found"
**Solution**: You may be using an old image. Pull latest: `docker pull henriqueslab/rxiv-maker-base:latest`

**Problem**: Scripts not found (workspace-setup.sh, usage.sh)  
**Solution**: These are included in images v2.5.0+. Update your image.

**Problem**: Looking for old dev-mode.sh or install-project-deps.sh
**Solution**: These are deprecated. Use the new direct terminal approach.

## Backwards Compatibility

- **Images v2.4.x and earlier**: Used APT + runtime dependency injection
- **Images v2.5.x and later**: Use UV + pre-installation (current)
- **Migration**: Update your workflows to use direct rxiv commands instead of setup scripts

## Documentation

- [Usage Instructions](scripts/usage.sh) - Available in container
- [Workspace Setup](scripts/workspace-setup.sh) - Available in container  
- [Build Process](docs/) - Technical documentation

---

**Architecture Version**: v2.5.0-uv-preinstalled
**Last Updated**: September 24, 2025
**Status**: ✅ All workflows operational after critical fixes
**Breaking Change**: Yes - migrated from runtime injection to pre-installation

### Recent Updates (Sept 24, 2025)
- ✅ **Fixed all GitHub Actions workflows** - resolved critical image tag mismatch
- ✅ **Corrected Dockerfile paths** - fixed build context issues
- ✅ **Updated test architecture** - proper local image verification
- ✅ **Streamlined across all workflows** - weekly, release, on-demand builds now working
