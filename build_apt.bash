#!/bin/bash

export LIBVA_DRIVER_NAME=iHD

sudo apt update

#sudo apt-get install libva-drm2 libva*
sudo apt-get install libva-dev
sudo apt-get install libmfx1 libmfx-tools libmfx-dev
sudo apt-get install i965-va-driver-shaders intel-media-va-driver-non-free
sudo apt-get install vainfo intel-gpu-tools
#sudo apt-get install vainfo xserver-xorg-video-intel
#sudo apt-get install autoconf libtool libdrm-dev xorg xorg-dev openbox libx11-dev libgl1-mesa-glx libgl1-mesa-dev

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
