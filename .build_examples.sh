#! /bin/bash
set -e

# Check the number of parameters.
if [ $# -ne 3 ]
then
  echo "The script needs 3 parameter:"
  echo "  1) the distribution ID"
  echo "  2) the distribution version (can be an empty string '')"
  echo "  3) the CPU architecture"
  exit -1
fi

JONCHKI_DISTRIBUTION_ID=$1
JONCHKI_DISTRIBUTION_VERSION=$2
JONCHKI_CPU_ARCHITECTURE=$3

if [ "${JONCHKI_DISTRIBUTION_VERSION}" == "" ]
then
	JONCHKI_PLATFORM_ID="${JONCHKI_DISTRIBUTION_ID}_${JONCHKI_CPU_ARCHITECTURE}"
else
	JONCHKI_PLATFORM_ID="${JONCHKI_DISTRIBUTION_ID}_${JONCHKI_DISTRIBUTION_VERSION}_${JONCHKI_CPU_ARCHITECTURE}"
fi
echo "Building jonchki for ${JONCHKI_PLATFORM_ID}"


JONCHKI_VERSION=0.0.3.1
JONCHKI_VERBOSE=info

# Get the project folder.
PRJ_DIR=`pwd`

# Install jonchki.
python2.7 jonchki/jonchkihere.py --jonchki-version ${JONCHKI_VERSION} --local-archives ${PRJ_DIR}/jonchki/local_archives ${PRJ_DIR}/build
if [ -f ${PRJ_DIR}/build/.jonchki.cmd ]; then
	JONCHKI=$(<${PRJ_DIR}/build/.jonchki.cmd)
fi
if [ "${JONCHKI}" == "" ]; then
	echo "Failed to extract the jonchki command from the jonchkihere output."
	exit 1
fi

# This is the base path where all packages will be assembled.
WORK_BASE=${PRJ_DIR}/build/examples
mkdir -p ${WORK_BASE}

# Does the jonchki configuration exist?
if [ ! -f ${WORK_BASE}/luaftdi-examples.xml ]; then
	echo "The jonchki configuration was not generated yet. Build the project first!"
	exit 1
fi

# This is the working folder for the current platform.
WORK=${WORK_BASE}/${JONCHKI_PLATFORM_ID}

# Remove the working folder and re-create it.
rm -rf ${WORK}
mkdir -p ${WORK}

# The common options are the same for all targets.
COMMON_OPTIONS="--syscfg ${PRJ_DIR}/examples/jonchki/jonchkisys.cfg --prjcfg ${PRJ_DIR}/examples/jonchki/jonchkicfg.xml --finalizer ${PRJ_DIR}/examples/jonchki/finalizer.lua ${WORK_BASE}/luaftdi-examples.xml"

# Build the artifact.
pushd ${WORK}
${JONCHKI} install-dependencies -v ${JONCHKI_VERBOSE} --distribution-id "${JONCHKI_DISTRIBUTION_ID}" --distribution-version "${JONCHKI_DISTRIBUTION_VERSION}" --cpu-architecture "${JONCHKI_CPU_ARCHITECTURE}" ${COMMON_OPTIONS}
popd
