# Do not call this script directly. It is included from the .build??_*.sh files.

echo "PRJ_DIR        = ${PRJ_DIR}"
echo "BUILD_DIR      = ${BUILD_DIR}"
echo "CMAKE_COMPILER = ${CMAKE_COMPILER}"

VERBOSITY=debug

# Create all folders.
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/external
mkdir -p ${BUILD_DIR}/lua5.1/build_requirements
mkdir -p ${BUILD_DIR}/lua5.1/luaftdi
mkdir -p ${BUILD_DIR}/lua5.2/build_requirements
mkdir -p ${BUILD_DIR}/lua5.2/luaftdi
mkdir -p ${BUILD_DIR}/lua5.3/build_requirements
mkdir -p ${BUILD_DIR}/lua5.3/luaftdi


# Install jonchki v0.0.2.1 .
python2.7 jonchki/jonchkihere.py --jonchki-version 0.0.2.1 --local-archives ${PRJ_DIR}/jonchki/local_archives ${BUILD_DIR}

# This is the path to the jonchki tool.
JONCHKI=${BUILD_DIR}/jonchki-0.0.2.1/jonchki


# Build the external components.
pushd ${BUILD_DIR}/external
cmake -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${PRJ_DIR}/external
make
popd


# Get the build requirements for lua5.1.
pushd ${BUILD_DIR}/lua5.1/build_requirements
cmake -DBUILDCFG_ONLY_JONCHKI_CFG="ON" -DBUILDCFG_LUA_VERSION="5.1" -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${PRJ_DIR}
make
${JONCHKI} --verbose ${VERBOSITY} --syscfg ${PRJ_DIR}/jonchki/jonchkisys.cfg --prjcfg ${PRJ_DIR}/jonchki/jonchkicfg.xml ${JONCHKI_SYSTEM} --build-dependencies luaftdi/luaftdi-*.xml
popd

# Build the luaftdi library for lua5.1.
pushd ${BUILD_DIR}/lua5.1/luaftdi
cmake -DBUILDCFG_LUA_USE_SYSTEM="OFF" -DBUILDCFG_LUA_VERSION="5.1" -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${PRJ_DIR}
make
make install DESTDIR=${BUILD_DIR}/lua5.1/install
popd


# Get the build requirements for lua5.2.
pushd ${BUILD_DIR}/lua5.2/build_requirements
cmake -DBUILDCFG_ONLY_JONCHKI_CFG="ON" -DBUILDCFG_LUA_VERSION="5.2" -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${PRJ_DIR}
make
${JONCHKI} --verbose ${VERBOSITY} --syscfg ${PRJ_DIR}/jonchki/jonchkisys.cfg --prjcfg ${PRJ_DIR}/jonchki/jonchkicfg.xml ${JONCHKI_SYSTEM} --build-dependencies luaftdi/luaftdi-*.xml
popd

# Build the luaftdi library for lua5.2.
pushd ${BUILD_DIR}/lua5.2/luaftdi
cmake -DBUILDCFG_LUA_USE_SYSTEM="OFF" -DBUILDCFG_LUA_VERSION="5.2" -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${PRJ_DIR}
make
make install DESTDIR=${BUILD_DIR}/lua5.2/install
popd


# Get the build requirements for lua5.3.
pushd ${BUILD_DIR}/lua5.3/build_requirements
cmake -DBUILDCFG_ONLY_JONCHKI_CFG="ON" -DBUILDCFG_LUA_VERSION="5.3" -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${PRJ_DIR}
make
${JONCHKI} --verbose ${VERBOSITY} --syscfg ${PRJ_DIR}/jonchki/jonchkisys.cfg --prjcfg ${PRJ_DIR}/jonchki/jonchkicfg.xml ${JONCHKI_SYSTEM} --build-dependencies luaftdi/luaftdi-*.xml
popd

# Build the luaftdi library for lua5.3.
pushd ${BUILD_DIR}/lua5.3/luaftdi
cmake -DBUILDCFG_LUA_USE_SYSTEM="OFF" -DBUILDCFG_LUA_VERSION="5.3" -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${PRJ_DIR}
make
make install DESTDIR=${BUILD_DIR}/lua5.3/install
popd
