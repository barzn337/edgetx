#! /usr/bin/env bash

## Bash script to show how to get EdgeTX source from GitHub
## and how to create an installation package.
## Let it run as normal user in MSYS2 MinGW 64-bit console (blue icon).
##
## Note #1: This script is tested to work properly only for the branch it stems from.
## Note #2: This script is intended for native Windows 64bit (mainly files naming...).
##
## @args:
## To pause after each step of the script invoke with --pause
## To delete the generated build output files when successfully finished invoke with --delout
## To delete the fetched source code when successfully finished invoke with --delsrc

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

export GIT_REPO="barzn337/edgetx"	# EdgeTX repo or any EdgeTX fork repo...
export BRANCH_NAME="2.9"	# main|2.9|...
export VER_NUM="2.9.0"
export VER_SUFF="barzn"
export VER_CODENAME="Providence"
export VER_FULL="v${VER_NUM}-${VER_SUFF}-${VER_CODENAME}"

export BDT="`date +%Y%m%d%H%M%S`"	# Build Date & Time
export PROJ_DIR="${HOME}/edgetx"
export SOURCE_DIR="${PROJ_DIR}/edgetx_${BRANCH_NAME}"
export BUILD_OUTPUT_DIR="${SOURCE_DIR}/build-output-cpn_${BDT}"
export RELEASE_DIR="${PROJ_DIR}/Release-${VER_FULL}_${BDT}"

export INSTALLER_FILE_NAME="companion-windows-${VER_FULL}.exe"

PAUSEAFTEREACHLINE="false" # true|false
DELETEBUILDOUTPUT="flase" # true|false
DELETESOURCECODE="false" # true|false

STEP=1
STEPS=9

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function log() {
    echo ""
    echo "=== [INFO] $*"
}

function fail() {
    echo "=== [ERROR] $*"
    exit 1
}

function check_command() {
    result=$1
    cli_info=$2
    if [[ $result -ne 0 ]]; then
        fail "${cli_info} (exit-code=$result)"
    else
        log "${cli_info} - OK"
        return 0
    fi
}

# Parse argument(s)
for arg in "$@"
do
	if [[ $arg == "--pause" ]]; then
		PAUSEAFTEREACHLINE="true"
	fi
	if [[ $arg == "--delout" ]]; then
		DELETEBUILDOUTPUT="true"
	fi
	if [[ $arg == "--delsrc" ]]; then
		DELETESOURCECODE="true"
	fi
done

echo "--- Build config: (Companion) ---"
echo "Build time: ${BDT}"
echo "GIT_REPO: ${GIT_REPO}"
echo "BRANCH_NAME: ${BRANCH_NAME}"
echo "PROJ_DIR: ${PROJ_DIR}"
echo "SOURCE_DIR: ${SOURCE_DIR}"
echo "BUILD_OUTPUT_DIR: ${BUILD_OUTPUT_DIR}"
echo "RELEASE_DIR: ${RELEASE_DIR}"
echo -e "\n\n"

echo "=== Step #$((STEP++))/$STEPS: Creating a directory for EdgeTX ==="
mkdir -p ${PROJ_DIR} && cd ${PROJ_DIR}
check_command $? "mkdir -p ${PROJ_DIR} && cd ${PROJ_DIR}"
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "=== Step #$((STEP++))/$STEPS: Fetching EdgeTX source tree (${BRANCH_NAME} branch) from GitHub ==="
  git clone --recursive -b ${BRANCH_NAME} https://github.com/${GIT_REPO}.git ${SOURCE_DIR}
  check_command $? "git clone --recursive -b ${BRANCH_NAME} https://github.com/${GIT_REPO}.git ${SOURCE_DIR}"
  cd ${SOURCE_DIR}
  check_command $? "cd ${SOURCE_DIR}"
else
  echo "=== Step #$((STEP++))/$STEPS: Updating EdgeTX source tree (${BRANCH_NAME} branch) from GitHub ==="
  cd ${SOURCE_DIR}
  check_command $? "cd ${SOURCE_DIR}"
  git checkout ${BRANCH_NAME}
  check_command $? "git checkout ${BRANCH_NAME}"
  git pull
  check_command $? "git pull"
  git submodule update --init --recursive
  check_command $? "git submodule update --init --recursive"
fi
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step #$((STEP++))/$STEPS: Creating build output directory ==="
mkdir -p ${BUILD_OUTPUT_DIR} && cd ${BUILD_OUTPUT_DIR}
check_command $? "mkdir -p ${BUILD_OUTPUT_DIR} && cd ${BUILD_OUTPUT_DIR}"
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step #$((STEP++))/$STEPS: Running CMake ==="
cmake -G "MSYS Makefiles" -Wno-dev -DCMAKE_PREFIX_PATH=$HOME/5.12.9/mingw73_64 -DSDL2_LIBRARY_PATH=/mingw64/bin/ -DVERSION_SUFFIX=${VER_SUFF} -DCMAKE_BUILD_TYPE=Release ../
check_command $? "cmake -G MSYS Makefiles -Wno-dev -DCMAKE_PREFIX_PATH=$HOME/5.12.9/mingw73_64 -DSDL2_LIBRARY_PATH=/mingw64/bin/ -DCMAKE_BUILD_TYPE=Release ../"
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step #$((STEP++))/$STEPS: Running Make configure ==="
make native-configure
check_command $? "make native-configure"
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step #$((STEP++))/$STEPS: Making an installer ==="
make -C native installer
check_command $? "make -C native installer"
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
fi

echo "=== Step #$((STEP++))/$STEPS: Renaming installer ==="
mv native/companion/companion-windows-${VER_NUM}.exe native/companion/${INSTALLER_FILE_NAME}
check_command $? "mv native/companion/companion-windows-${VER_NUM}.exe native/companion/${INSTALLER_FILE_NAME}"
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step #$((STEP++))/$STEPS: Creating release files directory ==="
mkdir -p ${RELEASE_DIR}
check_command $? "mkdir -p ${RELEASE_DIR}"
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step #$((STEP++))/$STEPS: Zipping release files ==="
cd ${BUILD_OUTPUT_DIR}/native/companion
check_command $? "cd ${BUILD_OUTPUT_DIR}/native/companion"
zip ${RELEASE_DIR}/edgetx-cpn-win64-v${VER_NUM}.zip ${INSTALLER_FILE_NAME}
check_command $? "zip ${RELEASE_DIR}/edgetx-cpn-win64-v${VER_NUM}.zip ${INSTALLER_FILE_NAME}"
cd ${SOURCE_DIR}
check_command $? "cd ${SOURCE_DIR}"
git archive -o edgetx-v${VER_NUM}.zip HEAD
check_command $? "git archive -o edgetx-v${VER_NUM}.zip HEAD"
mv edgetx-v${VER_NUM}.zip ${RELEASE_DIR}
check_command $? "mv edgetx-v${VER_NUM}.zip ${RELEASE_DIR}"
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo -e "Done.\n\n"
echo "Companion installer     : ${BUILD_OUTPUT_DIR}/native/companion/${INSTALLER_FILE_NAME}"
echo "Zipped release files at : ${RELEASE_DIR}"
echo -e "\n\n"

if [[ $DELETESOURCECODE == "true" ]]; then
  echo "Deleting the fecthed source code."
  rm -rf ${SOURCE_DIR}
  check_command $? "rm -rf ${SOURCE_DIR}"
elif [[ $DELETEBUILDOUTPUT == "true" ]]; then
  echo "Deleting the generated build output."
  rm -rf ${BUILD_OUTPUT_DIR}
  check_command $? "rm -rf ${BUILD_OUTPUT_DIR}"
fi

if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Job finished. Press Enter to open release files folder & exit."
  read
else
  echo "Job finished. Opening release files folder."
fi

cd ${RELEASE_DIR}
start .
exit
