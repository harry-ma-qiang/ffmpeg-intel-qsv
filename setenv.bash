export INSTALL_PATH="${PWD}/stage"
export PKG_CONFIG_PATH="${INSTALL_PATH}/lib/pkgconfig"
export LD_LIBRARY_PATH="${INSTALL_PATH}/lib:.:${LD_LIBRARY_PATH}"
export PATH="${INSTALL_PATH}/bin:.:${PATH}"
export NB_JOBS="$(nproc)"
export LIBVA_DRIVERS_PATH="${INSTALL_PATH}/lib"
export LIBVA_DRIVER_NAME=iHD
