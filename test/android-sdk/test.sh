#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'hello' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# Eg:
# {
#    'image': '<..some-base-image...>',
#    'features': {
#      'hello': {}
#    },
#    'remoteUser': 'root'
# }
#
# Thus, the value of all options will fall back to the default value in 
# the Feature's 'devcontainer-feature.json'.
# For the 'hello' feature, that means the default favorite greeting is 'hey'.
#
# These scripts are run as 'root' by default. Although that can be changed
# with the '--remote-user' flag.
# 
# This test can be run with the following command:
#
#    devcontainer features test \ 
#                   --features hello   \
#                   --remote-user root \
#                   --skip-scenarios   \
#                   --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#                   /path/to/this/repo

set -e

# Optional: Import test library bundled with the devcontainer CLI
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check 'Java is installed' which javac
check 'Android SDK root is set' echo "${ANDROID_SDK_ROOT}"
check 'Android command line tools installed' which sdkmanager
check 'Android accpet licenses' sdkmanager --licenses | grep  'All SDK package licenses accepted.'
check 'Platform tools are installed' sdkmanager --list_installed | grep  'platform-tools'
check 'Patcher installed' sdkmanager --list_installed | grep  "patcher;v${PATCHER_VERSION}"
check 'Platform installed' sdkmanager --list_installed | grep  "platforms;android-${PLATFORMS}"

if [ "${EMULATOR}" = 'true' ]; then
    check 'Emulator installed' sdkmanager --list_installed | grep  'emulator'
else
    check 'Emulator not installed' sdkmanager --list_installed | grep  -v 'emulator'
fi


# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults