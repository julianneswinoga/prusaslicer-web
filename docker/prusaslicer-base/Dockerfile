FROM ubuntu:24.04 AS build_step

ARG Z3_VERSION=4.8.12
ARG PRUSASLICER_VERSION=version_2.9.4

ENV DEBIAN_FRONTEND=noninteractive
RUN bash <<'EOF'
set -eu

misc_deps=(locales curl ca-certificates jq git)
# Packages needed to build PrusaSlicer from source
build_deps=(
    build-essential autoconf cmake texinfo file automake libtool
    # ./CMakeLists.txt
    libboost-all-dev
    libeigen3-dev libbtbb-dev libcurl4-openssl-dev zlib1g-dev libexpat1-dev libpng-dev libopengl-dev libglew-dev libcereal-dev libnlopt-cxx-dev
    libopenvdb-dev
    # libopenvdb sub-deps
    libimath-3-1-29 openexr
    # ./src/CMakeLists.txt
    libqhull-dev libgtk-3-dev libwxgtk3.2-dev libwxgtk-webview3.2-dev libjpeg-dev libnanosvg-dev
    # ./src/libslic3r/CMakeLists.txt
    libbgcode-dev libcgal-dev nlohmann-json3-dev
    # libbgcode sub-deps
    libheatshrink-dev
    # ./src/occt_wrapper/CMakeLists.txt
    libocct-ocaf-dev libocct-data-exchange-dev
    # ./src/slic3r/CMakeLists.txt
    libssl-dev libwebkit2gtk-4.1-dev
    # ./src/libseqarrange/CMakeLists.txt
    # libz3-dev - broken on 24.04, see below
    # z3 source dependencies
    python3-distutils-extra
)

apt-get update
apt-get install -y --no-install-recommends "${misc_deps[@]}" "${build_deps[@]}"

apt-get autoclean -y
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
EOF

# Locales
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Need to build z3 from source
# 24.04 ships with a broken install, Z3Config.cmake isn't found
# Required from src/libseqarrange/CMakeLists.txt
WORKDIR /z3
RUN <<'EOF'
set -eu

tarball_url=$(curl --show-error --silent --location https://api.github.com/repos/Z3Prover/z3/releases/tags/z3-${Z3_VERSION} | jq -r '.tarball_url')
echo "Downloading from $tarball_url"
curl --show-error --silent --location "$tarball_url" | tar xvzf - -C . --strip-components=1
EOF
RUN <<'EOF'
set -eu

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
cmake --install build
ldconfig
EOF

# Download source
WORKDIR /slic3r
RUN <<'EOF'
set -eu

tarball_url=$(curl --show-error --silent --location https://api.github.com/repos/prusa3d/PrusaSlicer/releases/tags/${PRUSASLICER_VERSION} | jq -r '.tarball_url')
echo "Downloading from $tarball_url"
curl --show-error --silent --location "$tarball_url" | tar xvzf - -C . --strip-components=1
EOF

# Patch source
# 24.04 installs OpenCASCADE 7.6.3, prusaslicer requires exactly 7.6.1
ADD permissive-opencascade-version.patch .
RUN git apply permissive-opencascade-version.patch

# Build source
RUN <<'EOF'
set -eu

cmake -S . -B build --preset shareddeps \
    -DSLIC3R_BUILD_TESTS=no \
    -DOPENVDB_FIND_MODULE_PATH=/usr/lib/x86_64-linux-gnu/cmake/OpenVDB/
cmake --build build -j$(nproc)
cmake --install build
EOF

# Final image
FROM ubuntu:24.04
COPY --from=build_step /usr/local /usr/local

ENV DEBIAN_FRONTEND=noninteractive
RUN bash <<'EOF'
set -eu

apt-get update
apt-get install -y --no-install-recommends \
    libboost-all-dev libqhullcpp8.0 libopenvdb-tools libnlopt0 libglew2.2 libcurl4t64 libwxgtk-gl3.2-1t64 libwxgtk-webview3.2-1t64

apt-get autoclean -y
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
EOF
