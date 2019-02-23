cmake_minimum_required(VERSION 3.2.3)

PROJECT("libftdi1")

INCLUDE(ExternalProject)

# Python is used for some test scripts.
FIND_PACKAGE(PythonInterp 2.7 REQUIRED)

SET(VERSION_EXTERNAL "1.4")


#----------------------------------------------------------------------------
#
# Build the project.
#

SET(PRJ_CMAKE_ARGS "")

LIST(APPEND PRJ_CMAKE_ARGS "-DSTATICLIBS=ON")
LIST(APPEND PRJ_CMAKE_ARGS "-DBUILD_TESTS=OFF")
LIST(APPEND PRJ_CMAKE_ARGS "-DDOCUMENTATION=OFF")
LIST(APPEND PRJ_CMAKE_ARGS "-DPYTHON_BINDINGS=OFF")
LIST(APPEND PRJ_CMAKE_ARGS "-DLINK_PYTHON_LIBRARY=OFF")
LIST(APPEND PRJ_CMAKE_ARGS "-DFTDIPP=OFF")

LIST(APPEND PRJ_CMAKE_ARGS "-Dlibusb_DIR='${CMAKE_BINARY_DIR}/libusb/install/cmake'")

LIST(APPEND PRJ_CMAKE_ARGS "-DPRJ_DIR=${PRJ_DIR}")
LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")

ExternalProject_Add(TARGET_libftdi1
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libftdi1-${VERSION_EXTERNAL}
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/libftdi1-${VERSION_EXTERNAL}.tar.bz2
                    URL_HASH SHA1=5b14cebab8168e12dd6c2b5325a29ad93ed40f3d
                    PATCH_COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/apply_patches.py --working-folder ${CMAKE_CURRENT_BINARY_DIR}/libftdi1-${VERSION_EXTERNAL}/src/TARGET_libftdi1 --patch-folder ${CMAKE_CURRENT_SOURCE_DIR}/patches --strip 1
                    CMAKE_ARGS ${PRJ_CMAKE_ARGS}
                    INSTALL_COMMAND make install DESTDIR=${CMAKE_CURRENT_BINARY_DIR}/install
)
# libftdi depends on libusb.
ADD_DEPENDENCIES(TARGET_libftdi1 TARGET_libusb)
