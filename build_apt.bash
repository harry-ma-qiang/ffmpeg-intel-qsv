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

sudo apt install -y gcc g++ make curl pkg-config yasm nasm
sudo apt install -y vainfo i965-va-driver xserver-xorg-video-intel xserver-xorg-core
#sudo apt install -y libx11-dev libgl1-mesa-glx libgl1-mesa-dev
sudo apt install -y libdrm-dev libva-dev libmfx-dev 
#sudo apt-get install libmfx1 libmfx-tools


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
