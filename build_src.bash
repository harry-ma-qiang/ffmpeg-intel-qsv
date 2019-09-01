#!/bin/bash

export INSTALL_PATH="/usr/"
export PKG_CONFIG_PATH="${INSTALL_PATH}/lib/pkgconfig"
export LD_LIBRARY_PATH="${INSTALL_PATH}/lib:${INSTALL_PATH}/lib/dri:."
export NB_JOBS="$(nproc)"
export LIBVA_DRIVERS_PATH="${INSTALL_PATH}/lib"
export LIBVA_DRIVER_NAME=iHD

function download() {
    URL="$1"; PKG="$2";
    cd "${INSTALL_PATH}"
    [ ! -f "${PKG}" ] && curl -kL -o "${PKG}" "${URL}" && tar -xvf "${PKG}"
}

mkdir -p "${INSTALL_PATH}"

#NOTE: Install this first:
#sudo apt install -y autoconf libtool libdrm-dev xorg xorg-dev openbox libx11-dev libgl1-mesa-glx libgl1-mesa-dev


# libva
if [ ! -f "${INSTALL_PATH}/lib/libva.so" ]; then
    download "https://github.com/intel/libva/archive/2.4.1.tar.gz" "libva-2.4.1.tar.gz"
    cd "libva-2.4.1"
    ./autogen.sh
    ./configure --prefix="${INSTALL_PATH}"
    make -j "${NB_JOBS}" && make install
    [ ! -f "${INSTALL_PATH}/lib/libva.so" ] && echo "compile libva failed" && exit 1
fi

# libva
if [ ! -f "${INSTALL_PATH}/bin/vainfo" ]; then
    download "https://github.com/intel/libva-utils/archive/2.4.1.tar.gz" "libva-utils-2.4.1.tar.gz"
    cd "libva-utils-2.4.1"
    ./autogen.sh
    ./configure --prefix="${INSTALL_PATH}"
    make -j "${NB_JOBS}" && make install
    [ ! -f "${INSTALL_PATH}/bin/vainfo" ] && echo "compile libva failed" && exit 1
fi

# gmmlib
if [ ! -f "${INSTALL_PATH}/lib/libigdgmm.so" ]; then
    download "https://github.com/intel/gmmlib/archive/intel-gmmlib-19.1.2.tar.gz" "intel-gmmlib-19.1.2.tar.gz"
    cd "gmmlib-intel-gmmlib-19.1.2"
    mkdir -p build && cd build
    cmake -D CMAKE_BUILD_TYPE=Release -D ARCH=64 -D CMAKE_INSTALL_LIBDIR="lib" -D CMAKE_INSTALL_PREFIX="${INSTALL_PATH}" ..
    make -j "${NB_JOBS}" && make install
    [ ! -f "${INSTALL_PATH}/lib/libigdgmm.so" ] && echo "compile intel-gmmlib failed" && exit 1
fi

# intel-media-driver
if [ ! -f "${INSTALL_PATH}/lib/libigfxcmrt.so" ]; then
    download "https://github.com/intel/media-driver/archive/intel-media-19.2.0.tar.gz" "media-driver-19.2.0.tar.gz"
    cd "media-driver-intel-media-19.2.0"
    mkdir -p build_media_driver && cd build_media_driver
    CXXFLAGS="-I${INSTALL_PATH}/include" CFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" \
    cmake -D LIBVA_INSTALL_PATH="${INSTALL_PATH}" -D CMAKE_INSTALL_LIBDIR="lib" -DENABLE_NONFREE_KERNELS=OFF \
    -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX="${INSTALL_PATH}" ..
    make -j "${NB_JOBS}" && make install
    [ ! -f "${INSTALL_PATH}/lib/libigfxcmrt.so" ] && echo "compile intel-media-driver failed" && exit 1
fi

# intel-media-sdk
if [ ! -f "${INSTALL_PATH}/lib/libmfx.so" ]; then
    download "https://github.com/Intel-Media-SDK/MediaSDK/archive/intel-mediasdk-19.1.0.tar.gz" "intel-mediasdk-19.1.0.tar.gz"
    cd "MediaSDK-intel-mediasdk-19.1.0"
    mkdir -p build_media_sdk && cd build_media_sdk
    CXXFLAGS="-I${INSTALL_PATH}/include" CFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" \
    cmake -D CMAKE_INSTALL_LIBDIR="lib" \
    -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX="${INSTALL_PATH}" ..
    make -j "${NB_JOBS}" && make install
    [ ! -f "${INSTALL_PATH}/lib/libmfx.so" ] && echo "compile intel-media-sdk failed" && exit 1
fi

# ffmpeg
if [ ! -f "${INSTALL_PATH}/bin/ffmpeg" ]; then
    Download from Ireland EC2: /home/ec2-user/inno-ffmpeg/inno-ffmpeg-4.2.tgz
    cd "ffmpeg-4.2"
    mkdir -p build && cd build
    ../configure --disable-shared --enable-static --disable-doc --disable-xvmc \
    --disable-iconv --disable-libxcb_shape --disable-libxcb_xfixes --disable-xlib --disable-libxcb \
    --disable-libxcb_shm --disable-lzma --disable-zlib --enable-libmfx \
    --prefix="${INSTALL_PATH}" \
    --extra-cflags="-I${INSTALL_PATH}/include" \
    --extra-cxxflags="-I${INSTALL_PATH}/include" \
    --extra-ldflags="-L${INSTALL_PATH}/lib" \
    --extra-libs='-lstdc++ -lpthread -lm -ldl'
    make -j "${NB_JOBS}" && make install
    [ ! -f "${INSTALL_PATH}/bin/ffmpeg" ] && echo "compile ffmpeg failed" && exit 1
fi
