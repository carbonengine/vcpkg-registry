# Copyright © 2025 CCP ehf.
# This toolchain is meant for use inside a vcpkg triplet. See `README.md` for more details.
include($ENV{PATH_TO_VCPKG_ROOT}/scripts/toolchains/osx.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../toolchains/x64-osx-carbon.cmake)
