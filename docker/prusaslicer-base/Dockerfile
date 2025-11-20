ARG UBUNTU_VERSION=24.04

FROM ubuntu:$UBUNTU_VERSION AS build_step

ARG Z3_TAG=z3-4.8.12
ARG PRUSASLICER_TAG=version_2.9.3

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
    # libz3-dev is still sorta broken on 24.04, see below
    libz3-dev
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

# Need to patch in z3 Cmake config
# 24.04 ships with a broken install, Z3Config.cmake isn't found
# https://github.com/Z3Prover/z3/issues/6496
# https://salsa.debian.org/pkg-llvm-team/z3/-/blob/master/debian/not-installed
ADD Z3Config.cmake /usr/lib/x86_64-linux-gnu/cmake/Z3/

# Download source
WORKDIR /slic3r
RUN <<'EOF'
set -eu

tarball_url=$(curl --show-error --silent --location https://api.github.com/repos/prusa3d/PrusaSlicer/releases/tags/${PRUSASLICER_TAG} | jq -r '.tarball_url')
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
    -DCMAKE_INSTALL_PREFIX=/opt/PrusaSlicer \
    -DSLIC3R_BUILD_TESTS=no \
    -DOPENVDB_FIND_MODULE_PATH=/usr/lib/x86_64-linux-gnu/cmake/OpenVDB/
cmake --build build -j$(nproc)
cmake --install build
EOF

# Final image
FROM ubuntu:$UBUNTU_VERSION
COPY --from=build_step /opt /opt
ENV PATH=${PATH}:/opt/PrusaSlicer/bin

ENV DEBIAN_FRONTEND=noninteractive
RUN bash <<'EOF'
set -eu

apt-get update
apt-get install -y --no-install-recommends \
    libboost-all-dev libqhullcpp8.0 libopenvdb-tools libnlopt0 libglew2.2 libcurl4t64 libwxgtk-gl3.2-1t64 libwxgtk-webview3.2-1t64 libz3-4

apt-get autoclean -y
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
EOF
