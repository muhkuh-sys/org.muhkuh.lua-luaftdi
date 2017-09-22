#! /bin/bash

# ----------------------------------------------------------------------------
#
# Try to get the VCS ID.
#
PROJECT_VERSION_VCS="unknown"
PROJECT_VERSION_VCS_LONG="unknown"
GIT_EXECUTABLE=$(which git)
STATUS=$?
if [ ${STATUS} -ne 0 ]
then
  echo "Git not found! Set the version to 'unknown'."
else
  GITV0=$(${GIT_EXECUTABLE} describe --abbrev=12 --always --dirty=+ --long)
  if [ ${STATUS} -ne 0 ]
  then
    echo "Failed to run Git! Set the version to 'unknown'."
  else
    if [[ ${GITV0} =~ ^[0-9a-f]+\+?$ ]]
    then
      echo 'This is a repository with no tags. Use the raw SHA sum.'
      PROJECT_VERSION_VCS="GIT${GITV0}"
      PROJECT_VERSION_VCS_LONG="GIT${GITV0}"
    elif [[ ${GITV0} =~ ^v([0-9.]+)-([0-9]+)-g([0-9a-f]+\+?)$ ]]
    then
      VCS_REVS_SINCE_TAG=${BASH_REMATCH[2]}
      if [ ${VCS_REVS_SINCE_TAG} -eq 0 ]
      then
        echo 'This is a repository which is exactly on a tag. Use the tag name.'
        PROJECT_VERSION_VCS="GIT${BASH_REMATCH[1]}"
        PROJECT_VERSION_VCS_LONG="GIT${BASH_REMATCH[1]}-${BASH_REMATCH[3]}"
      else
        echo 'This is a repository with commits after the last tag. Use the checkin ID.'
        PROJECT_VERSION_VCS="GIT${BASH_REMATCH[3]}"
        PROJECT_VERSION_VCS_LONG="GIT${BASH_REMATCH[3]}"
      fi
    else
      echo 'The description has an unknown format. Use the tag name.'
      PROJECT_VERSION_VCS="GIT${GITV0}"
      PROJECT_VERSION_VCS_LONG="GIT${GITV0}"
    fi
  fi
fi
echo "PROJECT_VERSION_VCS: ${PROJECT_VERSION_VCS}"
echo "PROJECT_VERSION_VCS_LONG: ${PROJECT_VERSION_VCS_LONG}"

# Errors are fatal from now on.
set -e

# Set the verbose level.
VERBOSE_LEVEL=debug

# Get the project folder.
PRJ_DIR=`pwd`
BUILD_DIR=${PRJ_DIR}/build/examples

# Install jonchki v0.0.1.1 .
python2.7 jonchki/jonchkihere.py --jonchki-version 0.0.1.1 ${BUILD_DIR}

# This is the path to the jonchki tool.
JONCHKI=${BUILD_DIR}/jonchki-0.0.1.1/jonchki

# Write the GIT version into the template.
rm -f ${BUILD_DIR}/luaftdi-examples.xml
sed --expression="s/\${PROJECT_VERSION_VCS}/${PROJECT_VERSION_VCS}/" ${PRJ_DIR}/examples/jonchki/luaftdi-examples.xml >${BUILD_DIR}/luaftdi-examples.xml

# Remove all working folders and re-create them.
rm -rf ${BUILD_DIR}/windows_32bit
rm -rf ${BUILD_DIR}/windows_64bit
rm -rf ${BUILD_DIR}/ubuntu_14.04_32bit
rm -rf ${BUILD_DIR}/ubuntu_14.04_64bit
rm -rf ${BUILD_DIR}/ubuntu_16.04_32bit
rm -rf ${BUILD_DIR}/ubuntu_16.04_64bit
rm -rf ${BUILD_DIR}/ubuntu_17.04_32bit
rm -rf ${BUILD_DIR}/ubuntu_17.04_64bit

mkdir -p ${BUILD_DIR}/windows_32bit
mkdir -p ${BUILD_DIR}/windows_64bit
mkdir -p ${BUILD_DIR}/ubuntu_14.04_32bit
mkdir -p ${BUILD_DIR}/ubuntu_14.04_64bit
mkdir -p ${BUILD_DIR}/ubuntu_16.04_32bit
mkdir -p ${BUILD_DIR}/ubuntu_16.04_64bit
mkdir -p ${BUILD_DIR}/ubuntu_17.04_32bit
mkdir -p ${BUILD_DIR}/ubuntu_17.04_64bit

# The common options are the same for all targets.
COMMON_OPTIONS="--syscfg ${PRJ_DIR}/examples/jonchki/jonchkisys.cfg --prjcfg ${PRJ_DIR}/examples/jonchki/jonchkicfg.xml --finalizer ${PRJ_DIR}/examples/jonchki/finalizer.lua ${BUILD_DIR}/luaftdi-examples.xml"

# Build the Windows_x86 artifact.
pushd ${BUILD_DIR}/windows_32bit
${JONCHKI} -v ${VERBOSE_LEVEL} --distribution-id windows --empty-distribution-version --cpu-architecture x86 ${COMMON_OPTIONS}
popd
# Build the Windows_x86_64 artifact.
pushd ${BUILD_DIR}/windows_64bit
${JONCHKI} -v ${VERBOSE_LEVEL} --distribution-id windows --empty-distribution-version --cpu-architecture x86_64 ${COMMON_OPTIONS}
popd

# Ubuntu 14.04 32bit
pushd ${BUILD_DIR}/ubuntu_14.04_32bit
${JONCHKI} -v ${VERBOSE_LEVEL} --distribution-id ubuntu --distribution-version 14.04 --cpu-architecture x86 ${COMMON_OPTIONS}
popd
# Ubuntu 14.04 64bit
pushd ${BUILD_DIR}/ubuntu_14.04_64bit
${JONCHKI} -v ${VERBOSE_LEVEL} --distribution-id ubuntu --distribution-version 14.04 --cpu-architecture x86_64 ${COMMON_OPTIONS}
popd

# Ubuntu 16.04 32bit
pushd ${BUILD_DIR}/ubuntu_16.04_32bit
${JONCHKI} -v ${VERBOSE_LEVEL} --distribution-id ubuntu --distribution-version 16.04 --cpu-architecture x86 ${COMMON_OPTIONS}
popd
# Ubuntu 16.04 64bit
pushd ${BUILD_DIR}/ubuntu_16.04_64bit
${JONCHKI} -v ${VERBOSE_LEVEL} --distribution-id ubuntu --distribution-version 16.04 --cpu-architecture x86_64 ${COMMON_OPTIONS}
popd

# Ubuntu 17.04 32bit
pushd ${BUILD_DIR}/ubuntu_17.04_32bit
${JONCHKI} -v ${VERBOSE_LEVEL} --distribution-id ubuntu --distribution-version 17.04 --cpu-architecture x86 ${COMMON_OPTIONS}
popd
# Ubuntu 17.04 64bit
pushd ${BUILD_DIR}/ubuntu_17.04_64bit
${JONCHKI} -v ${VERBOSE_LEVEL} --distribution-id ubuntu --distribution-version 17.04 --cpu-architecture x86_64 ${COMMON_OPTIONS}
popd
