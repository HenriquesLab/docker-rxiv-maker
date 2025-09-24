# Docker Infrastructure for Rxiv-Maker

Docker image building infrastructure for rxiv-maker with pre-installed rxiv-maker via UV.

## Architecture

**v2.5.0+**: rxiv-maker is pre-installed during Docker build via UV
**v2.4.x**: Runtime dependency injection (deprecated)

### Key Changes
- rxiv-maker pre-installed via UV during build
- Direct terminal usage, no runtime installation
- Faster startup (~3s vs 30-60s)
- Consistent versions locked at build time

## Build Schedule

- **Weekly**: Monday 2 AM UTC with latest rxiv-maker
- **On-Demand**: Manual workflow dispatch
- **Release**: Triggered by rxiv-maker releases

## Repository Structure

```
docker-rxiv-maker/
├── .github/workflows/       # CI/CD workflows
├── images/base/            # Dockerfile and build scripts
├── scripts/                # Helper scripts (in container)
├── docs/                   # Technical documentation
└── tests/                  # Build verification
```

## Quick Start

### Interactive Terminal

```bash
# Start container with your manuscript
docker run -it --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest

# Inside container - rxiv-maker is already installed
rxiv pdf ./my-manuscript/
rxiv validate ./my-manuscript/
rxiv --help
```

### Direct Command Execution

```bash
# Generate PDF
docker run --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest rxiv pdf .

# Validate manuscript
docker run --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest rxiv validate .
```

### Helper Scripts

Available inside container:
- `workspace-setup.sh` - Interactive workspace setup
- `usage.sh` - Usage instructions
- `rxiv --version` - Check version

## Migration from v2.4.x

Old (deprecated):
```bash
docker run -it --rm -v $(pwd):/workspace image:latest dev-mode.sh
```

Current:
```bash
docker run -it --rm -v $(pwd):/workspace image:latest
# rxiv commands work immediately
```

## Image Details

- **Repository**: `henriqueslab/rxiv-maker-base`
- **Tags**: `latest`, `v2.5.x`
- **Platforms**: AMD64, ARM64
- **Contents**:
  - rxiv-maker (pre-installed via UV)
  - TeX Live (complete LaTeX)
  - Python 3.11 + scientific libraries
  - R + graphics packages
  - Mermaid.ink API support

## Building Locally

```bash
cd images/base
./build.sh           # Build local
./build.sh --push    # Build and push
```

## Troubleshooting

**"rxiv command not found"**
Pull latest image: `docker pull henriqueslab/rxiv-maker-base:latest`

**"workspace-setup.sh not found"**
Update to v2.5.0+

**Looking for dev-mode.sh**
Deprecated. Use direct terminal approach.

## Recent Fixes (Sept 24, 2025)

- Fixed GitHub Actions workflow failures (image tag mismatch)
- Corrected Dockerfile paths and labels
- Updated test architecture for local image verification

---

**Version**: v2.5.0-uv-preinstalled
**Updated**: September 24, 2025
**Status**: Operational