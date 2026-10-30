# Copyright © 2026 CCP ehf.

# This toolchain is meant for use inside a vcpkg triplet. See `README.md` for more details.
include($ENV{PATH_TO_VCPKG_ROOT}/scripts/toolchains/linux.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/arm64-linux-carbon.cmake)
