#!/bin/bash

export INSTALL_PATH="${PWD}/stage"
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

sudo apt install -y gcc g++ make curl pkg-config yasm nasm cmake autoconf libtool

# zlib
if [ ! -f "${INSTALL_PATH}/lib/libz.a" ]; then
    download "https://www.zlib.net/zlib-1.2.11.tar.gz" "zlib-1.2.11.tar.gz"
    cd "zlib-1.2.11"
    ./configure --64 --prefix="${INSTALL_PATH}" #--static
    make -j "${NB_JOBS}" && make install
    [ ! -f "${INSTALL_PATH}/lib/libz.a" ] && echo "compile zlib failed" && exit 1
fi

# libpciaccess
if [ ! -f "${INSTALL_PATH}/lib/libpciaccess.a" ]; then
    download "https://xorg.freedesktop.org/archive/individual/lib/libpciaccess-0.14.tar.gz" "libpciaccess-0.14.tar.gz"
    cd "libpciaccess-0.14"
    ./configure --prefix="${INSTALL_PATH}" --enable-static --enable-shared
    make check
    make -j "${NB_JOBS}" && make install
    [ ! -f "${INSTALL_PATH}/lib/libpciaccess.a" ] && echo "compile libpciaccess failed" && exit 1
fi

# libdrm
if [ ! -f "${INSTALL_PATH}/lib/libdrm.a" ]; then
    download "https://dri.freedesktop.org/libdrm/libdrm-2.4.99.tar.gz" "libdrm-2.4.99.tar.gz"
    cd "libdrm-2.4.99"
    ./configure --prefix="${INSTALL_PATH}" --enable-static --enable-shared
    make -j "${NB_JOBS}" && make install
    [ ! -f "${INSTALL_PATH}/lib/libdrm.a" ] && echo "compile libdrm failed" && exit 1
fi

# libva
if [ ! -f "${INSTALL_PATH}/lib/libva.a" ]; then
    download "https://github.com/intel/libva/archive/2.5.0.tar.gz" "libva-2.5.0.tar.gz"
    cd "libva-2.5.0"
    ./autogen.sh
    ./configure --prefix="${INSTALL_PATH}" --enable-static --enable-shared
    make -j "${NB_JOBS}" && make install
    [ ! -f "${INSTALL_PATH}/lib/libva.a" ] && echo "compile libva failed" && exit 1
fi

# intel-vaapi-driver
if [ ! -f "${INSTALL_PATH}/lib/i965_drv_video.so" ]; then
    download "https://github.com/intel/intel-vaapi-driver/archive/2.3.0.tar.gz" "intel-vaapi-driver.2.3.0.tar.gz"
    cd "intel-vaapi-driver-2.3.0"
    ./autogen.sh
    ./configure --prefix="${INSTALL_PATH}" --enable-static --enable-shared
    make -j "${NB_JOBS}" && make install
    [ ! -f "${INSTALL_PATH}/lib/i965_drv_video.so" ] && echo "compile intel-vaapi-driver failed" && exit 1
fi

# gmmlib
if [ ! -f "${INSTALL_PATH}/lib/libigdgmm.so" ]; then
    download "https://github.com/intel/gmmlib/archive/intel-gmmlib-19.2.3.tar.gz" "intel-gmmlib-19.2.3.tar.gz"
    cd "gmmlib-intel-gmmlib-19.2.3"
    mkdir -p build && cd build
    cmake -D CMAKE_BUILD_TYPE=Release -D ARCH=64 -D CMAKE_INSTALL_LIBDIR="lib" \
-D BUILD_SHARED_LIBS=OFF -D CMAKE_INSTALL_PREFIX="${INSTALL_PATH}" ..
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
    download "https://github.com/Intel-Media-SDK/MediaSDK/archive/intel-mediasdk-19.2.1.tar.gz" "intel-mediasdk-19.2.1.tar.gz"
    cd "MediaSDK-intel-mediasdk-19.2.1"
    mkdir -p build_media_sdk && cd build_media_sdk
    CXXFLAGS="-I${INSTALL_PATH}/include" CFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" \
cmake -D CMAKE_INSTALL_LIBDIR="lib" \
-D MFX_ENABLE_KERNELS=ON \
-D BUILD_TOOLS=ON \
-D BUILD_TESTS=ON \
-D BUILD_SAMPLES=ON \
-D BUILD_RUNTIME=ON \
-D BUILD_KERNELS=ON \
-D ENABLE_X11_DRI3=ON \
-D ENABLE_STAT=ON \
-D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX="${INSTALL_PATH}" ..
    make -j "${NB_JOBS}" && make install
    [ ! -f "${INSTALL_PATH}/lib/libmfx.so" ] && echo "compile intel-media-sdk failed" && exit 1
fi

# ffmpeg
if [ ! -f "${INSTALL_PATH}/bin/ffmpeg2" ]; then
    download "https://ffmpeg.org/releases/ffmpeg-4.2.tar.bz2" "ffmpeg-4.2.tar.bz2"
    cd "ffmpeg-4.2"
    mkdir -p build && cd build
    ../configure --enable-shared --enable-static --disable-doc --disable-xvmc \
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
