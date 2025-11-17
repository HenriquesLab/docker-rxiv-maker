FROM ubuntu:22.04

# Build arguments for version and metadata
ARG RXIV_VERSION="latest"
ARG BUILD_DATE
ARG BUILDKIT_INLINE_CACHE=1
ARG RXIV_SOURCE="pypi"
ARG RXIV_REPO_URL="https://github.com/HenriquesLab/rxiv-maker.git"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Set locale to avoid locale warnings
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Create retry helper script for handling transient apt mirror errors
RUN printf '#!/bin/bash\n\
set -e\n\
max_attempts=3\n\
attempt=1\n\
while [ $attempt -le $max_attempts ]; do\n\
    echo "[Attempt $attempt/$max_attempts] Running: $*"\n\
    if "$@"; then\n\
        echo "[Success] Command succeeded"\n\
        exit 0\n\
    fi\n\
    exit_code=$?\n\
    if [ $attempt -lt $max_attempts ]; then\n\
        sleep_time=$((attempt * 10))\n\
        echo "[Retry] Command failed with exit code $exit_code. Retrying in ${sleep_time}s..."\n\
        sleep $sleep_time\n\
    else\n\
        echo "[Failed] Command failed after $max_attempts attempts with exit code $exit_code"\n\
        exit $exit_code\n\
    fi\n\
    attempt=$((attempt + 1))\n\
done\n' > /usr/local/bin/retry && chmod +x /usr/local/bin/retry

# Update package lists and install core system dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    retry bash -c 'apt-get update && apt-get install -y --no-install-recommends \
    # Core system utilities
    curl \
    wget \
    unzip \
    ca-certificates \
    software-properties-common \
    gnupg \
    lsb-release \
    # Build toolchain
    build-essential \
    make \
    cmake \
    pkg-config \
    gcc \
    g++ \
    gfortran \
    # Development libraries
    libjpeg-dev \
    libpng-dev \
    libtiff5-dev \
    python3-dev \
    libffi-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    # Version control
    git'

# Install R and essential system R packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    retry bash -c 'apt-get update && apt-get install -y --no-install-recommends \
    r-base \
    r-base-dev \
    # Basic R packages available in Ubuntu
    r-cran-ggplot2 \
    r-cran-dplyr \
    r-cran-scales \
    r-cran-readr \
    r-cran-tidyr \
    r-cran-svglite'

# Install Ubuntu's pre-compiled R packages (key optimization)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    retry bash -c 'apt-get update && apt-get install -y --no-install-recommends \
    # Core infrastructure packages
    r-cran-cli \
    r-cran-rlang \
    r-cran-lifecycle \
    r-cran-vctrs \
    r-cran-magrittr \
    r-cran-stringi \
    r-cran-stringr \
    # Network and data packages
    r-cran-httr \
    r-cran-jsonlite \
    r-cran-xml2 \
    r-cran-lubridate \
    r-cran-rvest \
    # Graphics packages (these were the problematic ones!)
    r-cran-systemfonts \
    r-cran-ragg \
    # Academic publishing and command-line packages
    r-cran-optparse \
    r-cran-cairo \
    r-cran-gridextra \
    r-cran-knitr \
    r-cran-rmarkdown \
    r-cran-devtools \
    # Statistical and data manipulation packages
    r-cran-reshape2 \
    r-cran-plyr \
    r-cran-car \
    && rm -rf /var/lib/apt/lists/*'

# Install fonts first (before LaTeX to avoid conflicts)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    retry bash -c 'apt-get update && apt-get install -y --no-install-recommends \
    # Essential fonts for LaTeX compilation
    fonts-liberation \
    fonts-dejavu-core \
    fonts-lmodern \
    fonts-texgyre \
    fonts-dejavu \
    fonts-liberation2 \
    fonts-noto-core \
    # Font configuration tools
    fontconfig \
    fontconfig-config \
    && fc-cache -fv \
    && rm -rf /var/lib/apt/lists/*'

# Configure Posit Package Manager for binary R packages (10x speed boost)
RUN echo 'options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"))' >> /etc/R/Rprofile.site \
    && echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' >> /etc/R/Rprofile.site \
    && echo '# Configure Posit Package Manager for Ubuntu 22.04 binary packages' >> /etc/R/Rprofile.site \
    && echo '# This provides pre-compiled binaries instead of source compilation' >> /etc/R/Rprofile.site

# Install LaTeX with minimal essential packages only
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    retry bash -c 'apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-latex-extra \
    texlive-science \
    texlive-pstricks \
    biber \
    && rm -rf /var/lib/apt/lists/*'

# Add deadsnakes PPA for Python 3.11
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    retry bash -c 'add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    file \
    && rm -rf /var/lib/apt/lists/*'

# Set Python 3.11 as default and install uv
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel \
    && curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/root/.local/bin:$PATH"
RUN cp /root/.local/bin/uv /usr/local/bin/uv && chmod +x /usr/local/bin/uv

# Install Python packages in optimized dependency order
# Core scientific stack (most stable, install first)
RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    uv pip install --system --no-cache-dir \
    "numpy>=1.24.0,<2.0.0" \
    "scipy>=1.10.0,<2.0.0" \
    "pandas>=2.0.0,<3.0.0" \
    "Pillow>=9.0.0,<11.0.0" \
    "PyYAML>=6.0.0,<7.0.0"

# Graphics and visualization (moderate stability)
RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    uv pip install --system --no-cache-dir \
    "matplotlib>=3.7.0,<3.9.0" \
    "seaborn>=0.12.0,<0.14.0"

# Document and network libraries (moderate stability)
RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    uv pip install --system --no-cache-dir \
    "requests>=2.28.0,<3.0.0" \
    "svglib>=1.5.0,<2.0.0" \
    "reportlab>=4.0.0,<5.0.0" \
    "defusedxml>=0.7.0,<1.0.0" \
    "lxml>=4.9.0,<6.0.0" \
    "pypdf>=3.0.0,<5.0.0"

# Application utilities (higher change frequency, install last)
RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    uv pip install --system --no-cache-dir \
    "python-dotenv>=1.0.0,<2.0.0" \
    "crossref-commons>=0.0.7,<1.0.0" \
    "platformdirs>=4.0.0,<5.0.0" \
    "click>=8.0.0,<9.0.0" \
    "rich>=13.0.0,<14.0.0" \
    "rich-click>=1.6.0,<2.0.0" \
    "typing-extensions>=4.0.0,<5.0.0" \
    "packaging>=21.0.0,<25.0.0" \
    "tomli-w>=1.0.0,<2.0.0" \
    "tomli>=2.0.0,<3.0.0" \
    "ruff>=0.8.0,<1.0.0"

# Create a non-root user for security
RUN groupadd -r rxivmaker && useradd -r -g rxivmaker -d /home/rxivmaker -s /bin/bash rxivmaker \
    && mkdir -p /home/rxivmaker \
    && chown rxivmaker:rxivmaker /home/rxivmaker

# Set up working directory
WORKDIR /workspace

# Create necessary directories with proper permissions
RUN mkdir -p /workspace/output /workspace/cache /tmp/texmf-var /home/rxivmaker/.R/library \
    && chown -R rxivmaker:rxivmaker /workspace /tmp/texmf-var /home/rxivmaker \
    && chmod -R 777 /workspace /tmp/texmf-var

# Set environment variables for LaTeX
ENV TEXMFVAR=/tmp/texmf-var
ENV TEXMFHOME=/tmp/texmf-home
ENV TEXMFCACHE=/tmp/texmf-cache

# Font configuration for LaTeX
ENV FONTCONFIG_FILE=/etc/fonts/fonts.conf
ENV FC_CACHE_DIR=/tmp/fontconfig-cache

# Set environment variables for R
ENV R_LIBS_USER=/home/rxivmaker/.R/library

# Install rxiv-maker via UV during build time (CRITICAL FOR NEW POLICY)
RUN echo "[INFO] Installing rxiv-maker via UV during Docker build..." && \
    if [ "$RXIV_SOURCE" = "repo" ]; then \
        echo "[INFO] Installing from repository: $RXIV_REPO_URL" && \
        uv pip install --system "git+${RXIV_REPO_URL}" --no-cache-dir; \
    else \
        echo "[INFO] Installing from PyPI" && \
        uv pip install --system rxiv-maker --no-cache-dir; \
    fi && \
    echo "[SUCCESS] Rxiv-maker installed!" && \
    rxiv --version

# Verify installation during build to catch issues early
RUN echo "[INFO] Verifying rxiv-maker installation..." && \
    rxiv --version && \
    echo "✅ Rxiv-maker ready for terminal usage"

# Copy terminal-focused helper scripts
COPY scripts/workspace-setup.sh /usr/local/bin/workspace-setup.sh
COPY scripts/usage.sh /usr/local/bin/usage.sh
RUN chmod +x /usr/local/bin/workspace-setup.sh /usr/local/bin/usage.sh

# Add labels for metadata
LABEL maintainer="Rxiv-Maker Project"
LABEL description="Ubuntu-based Docker Image with Pre-installed Rxiv-Maker via UV - Ready for Terminal Usage"
LABEL version="2.5.0-working-test"
LABEL org.opencontainers.image.source="https://github.com/henriqueslab/docker-rxiv-maker"
LABEL org.opencontainers.image.description="Ubuntu-based image with rxiv-maker pre-installed via UV for direct terminal usage"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.variant="working-test"
LABEL org.opencontainers.image.title="Rxiv-Maker Base Image"
LABEL org.opencontainers.image.vendor="HenriquesLab"
LABEL rxiv-maker.version="${RXIV_VERSION}"
LABEL rxiv-maker.source="${RXIV_SOURCE}"
LABEL rxiv-maker.repo-url="${RXIV_REPO_URL}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"

# For GitHub Actions, we need to stay as root to allow workspace access
# USER rxivmaker

CMD ["/bin/bash"]