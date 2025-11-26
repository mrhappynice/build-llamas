ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION} AS build

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
RUN apt-get update && apt-get install -y --no-install-recommends tzdata ca-certificates \
 && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata

# base tools + deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential ninja-build pkg-config \
    wget curl xz-utils gpg software-properties-common \
    libxcb-xinput0 libxcb-xinerama0 libxcb-cursor-dev \
    # >>> curl headers (fixes your error)
    libcurl4-openssl-dev zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

# newer CMake on 20.04 (Kitware repo)
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc \
  | gpg --dearmor -o /usr/share/keyrings/kitware-archive-keyring.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main" \
    > /etc/apt/sources.list.d/kitware.list \
 && apt-get update && apt-get install -y --no-install-recommends cmake \
 && rm -rf /var/lib/apt/lists/*

# Vulkan SDK
ARG VULKAN_VERSION=1.4.321.1
ENV VULKAN_SDK=/opt/vulkan
ENV PATH=$VULKAN_SDK/bin:$PATH
ENV LD_LIBRARY_PATH=$VULKAN_SDK/lib:$LD_LIBRARY_PATH
ENV CMAKE_PREFIX_PATH=$VULKAN_SDK:$CMAKE_PREFIX_PATH
ENV PKG_CONFIG_PATH=$VULKAN_SDK/lib/pkgconfig:$PKG_CONFIG_PATH

RUN ARCH=$(uname -m) \
 && wget -qO /tmp/vulkan-sdk.tar.xz \
      "https://sdk.lunarg.com/sdk/download/${VULKAN_VERSION}/linux/vulkan-sdk-linux-${ARCH}-${VULKAN_VERSION}.tar.xz" \
 && mkdir -p /opt/vulkan \
 && tar -xf /tmp/vulkan-sdk.tar.xz -C /tmp --strip-components=1 \
 && mv /tmp/${ARCH}/* /opt/vulkan/ \
 && rm -rf /tmp/*

WORKDIR /app
COPY . .

# Build (keep old glibc baseline, static libstdc++/libgcc)
RUN cmake -B build -G Ninja \
      -DGGML_VULKAN=ON \
      -DLLAMA_BUILD_SERVER=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_FLAGS="-O3 -fPIC" \
      -DCMAKE_CXX_FLAGS="-O3 -fPIC -static-libstdc++ -static-libgcc" \
 && cmake --build build --config Release -j"$(nproc)"

