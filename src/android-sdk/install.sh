#!/usr/bin/env sh
set -ex

URL="https://dl.google.com/android/repository"
ARCHIVE="commandlinetools-linux-${COMMAND_LINE_TOOLS_VERSION}_latest.zip"
FOLDER="cmdline-tools"

# Install apt dependencies
APT_PACKAGES=""
if ! which wget 2>&1 >/dev/null ; then
    APT_PACKAGES="${APT_PACKAGES} wget"
fi

if ! which unzip 2>&1 >/dev/null ; then
    APT_PACKAGES="${APT_PACKAGES} unzip"
fi

if ! which javac 2>&1 >/dev/null ; then
    APT_PACKAGES="${APT_PACKAGES} openjdk-17-jdk-headless"
fi

# shellcheck disable=SC2086
apt-get update && apt-get install -y ${APT_PACKAGES} && apt-get clean

# Create the folder for the Android SDK
mkdir -p "$ANDROID_SDK_ROOT/$FOLDER" 
chown -R "$_REMOTE_USER:$_REMOTE_USER" "$ANDROID_SDK_ROOT"

# Swap to the user that will be running the Android SDK
su - "$_REMOTE_USER"

# Download and extract the latest Android SDK command line tools
wget -q "${URL}/${ARCHIVE}"
unzip "${ARCHIVE}"
mv "${FOLDER}" "${ANDROID_SDK_ROOT}/${FOLDER}/latest"
rm "${ARCHIVE}"

SDK_PACKAGES="platform-tools patcher;v4"
if ! [ "${PLATFORMS}" = "none" ]; then
    SDK_PACKAGES="${SDK_PACKAGES} platforms;android-${PLATFORMS}"
fi

if ! [ "${BUILD_TOOLS}" = "none" ]; then
    SDK_PACKAGES="${SDK_PACKAGES} build-tools;${BUILD_TOOLS}"
fi

if [ "${EMULATOR}" = 'true' ]; then
    SDK_PACKAGES="${SDK_PACKAGES} emulator"
fi

yes | sdkmanager --licenses

# shellcheck disable=SC2086
sdkmanager --install ${SDK_PACKAGES}