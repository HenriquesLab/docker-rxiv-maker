[![DOI: 10.1242/jcs.265183](https://img.shields.io/badge/DOI-10.1242%2Fjcs.265183-blue)](https://doi.org/10.1242/jcs.265183)
[![arXiv](https://img.shields.io/badge/arXiv-2508.00836-b31b1b.svg)](https://arxiv.org/abs/2508.00836)

# Docker Infrastructure for Rxiv-Maker

**Streamlined Docker build system** for rxiv-maker with pre-installed rxiv-maker via UV.

## 🎯 **Quick Start**

### Using Pre-built Images

```bash
# Interactive terminal with your manuscript
docker run -it --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest

# Direct command execution
docker run --rm -v $(pwd):/workspace henriqueslab/rxiv-maker-base:latest rxiv pdf .
```

### Building Locally

```bash
# Simple build (from images/base directory)
cd images/base && ./build.sh --local

# Build and push to registry
cd images/base && ./build.sh --tag v1.8.1

# Test existing image
./test-docker-image.sh henriqueslab/rxiv-maker-base:latest

# Or use Makefile (recommended)
cd images/base && make image-build
cd images/base && make image-push
```

## 🏗️ **Architecture**

**Current (v2.5.0+)**: Pre-installed rxiv-maker via UV during Docker build
- ✅ **Direct terminal usage** - no runtime installation
- ✅ **Fast startup** (~3s vs 30-60s)
- ✅ **Consistent versions** locked at build time
- ✅ **Streamlined CI** - single workflow instead of 5+

## 📁 **Repository Structure**

```
docker-rxiv-maker/
├── .github/workflows/
│   ├── docker.yml                  # Unified CI workflow
│   └── gemini-*.yml               # AI assistant workflows
├── images/base/
│   ├── Dockerfile                 # Production image definition
│   ├── build.sh                   # Build script
│   └── Makefile                   # Build automation
├── scripts/                       # Helper scripts (in container)
├── test-docker-image.sh           # Comprehensive test suite
├── tests/                         # Test files
└── LICENSE                        # MIT License
```


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

## 🔧 **Streamlined Build System**

### **For Developers**

```bash
# Local development build
cd images/base && ./build.sh --local --platform linux/amd64

# Production build and push
cd images/base && ./build.sh --tag latest

# Test any image
./test-docker-image.sh henriqueslab/rxiv-maker-base:dev
```

### **CI/CD Workflow**

Single unified workflow handles all scenarios:
- **Push to main**: Builds and pushes `dev` tag with repository source
- **Weekly schedule**: Builds `latest` + `weekly` tags with PyPI source
- **Releases**: Builds `latest` + version tags with PyPI source
- **Manual dispatch**: Flexible build options with source selection

## 📦 **Image Details**

- **Repository**: `henriqueslab/rxiv-maker-base`
- **Tags**: `latest`, `dev`, `weekly`, version tags (e.g., `v1.8.1`)
- **Platforms**: AMD64, ARM64
- **Size**: ~2GB (optimized)
- **Contents**:
  - ✅ rxiv-maker (pre-installed via UV)
  - ✅ TeX Live (complete LaTeX)
  - ✅ Python 3.11 + scientific libraries
  - ✅ R + graphics packages
  - ✅ All system dependencies

### 🏷️ **Tag Strategy**

| Tag | rxiv-maker Source | Usage | Update Frequency |
|-----|------------------|--------|------------------|
| **`latest`** | 🔗 **PyPI releases** | ✅ **Production** | On GitHub releases |
| **`dev`** | 📦 **GitHub repository** | ⚠️ **Development** | On main branch pushes |
| **`weekly`** | 🔗 **PyPI releases** | 🔄 **Fresh packages** | Every Monday 2AM UTC |
| **`v1.8.1`** | 🔗 **PyPI releases** | 📌 **Pinned version** | Manual releases |

### 📋 **Recommended Usage**

```bash
# Production use (stable PyPI releases)
docker run henriqueslab/rxiv-maker-base:latest

# Development testing (latest repository code)
docker run henriqueslab/rxiv-maker-base:dev

# Weekly refreshed packages (latest security updates)
docker run henriqueslab/rxiv-maker-base:weekly

# Specific version (reproducible builds)
docker run henriqueslab/rxiv-maker-base:v1.8.1
```

## 🔧 **Troubleshooting**

**Build failures**: Check GitHub Actions logs in the unified `docker.yml` workflow

**"rxiv command not found"**: Pull latest image or rebuild:
```bash
docker pull henriqueslab/rxiv-maker-base:latest
```

**Local build issues**: Use the build script or Makefile:
```bash
cd images/base && ./build.sh --help
# or
cd images/base && make help
```

**Old workflows not working**: The system has been streamlined - use the new tools above

## 🔄 **Recent Streamlining (Sept 29, 2025)**

**Repository Cleanup & Optimization:**
- ✅ **Eliminated redundancy** - removed 15+ duplicate files
- ✅ **Consolidated workflows** - single unified Docker workflow
- ✅ **Streamlined build tools** - single source of truth (build.sh)
- ✅ **Modernized Makefile** - updated for new architecture
- ✅ **Simplified structure** - removed broken/deprecated scripts
- ✅ **Maintained functionality** - all features preserved

## 📝 **Important Notes**

**Multi-Platform Support:**
- AMD64 and ARM64 both supported
- ARM64 builds use QEMU (slower but necessary)
- Weekly builds refresh all packages (intentional for security)

**Build Performance:**
- Local builds: ~5-10 minutes (single platform)
- Multi-platform builds: ~30 minutes (Docker Hub push)
- Container startup: ~3 seconds (pre-installed rxiv-maker)

---

### 🔧 **Helper Scripts**

Available inside container:
- `workspace-setup.sh` - Interactive workspace setup
- `usage.sh` - Usage instructions
- `rxiv --version` - Check version

###  **Citation**

If you use Rxiv-Maker or these Docker images in your research, please cite:

```bibtex
@article{saraiva_2025_rxivmaker,
  title={Rxiv-Maker: An automated template engine for streamlined scientific publications},
  author={Bruno M. Saraiva and Rita Carlota and António D. Brito and Iván Hidalgo-Cenalmor and Guillaume Jacquemet and Ricardo Henriques},
  journal={Journal of Cell Science},
  year={2026},
  doi={10.1242/jcs.265183},
  url={https://doi.org/10.1242/jcs.265183}
}
```

- **Journal Article**: [10.1242/jcs.265183](https://doi.org/10.1242/jcs.265183) (*Journal of Cell Science*)
- **Preprint**: [10.48550/arXiv.2508.00836](https://doi.org/10.48550/arXiv.2508.00836) (arXiv)

### 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Version**: v2.5.0-streamlined
**Updated**: September 29, 2025
**Status**: Fully Operational 🚀