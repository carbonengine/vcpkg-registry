# Copyright © 2026 CCP ehf.

if (NOT _CCP_TOOLCHAIN_FILE_LOADED)
    set(_CCP_TOOLCHAIN_FILE_LOADED 1)

    set (VCPKG_USE_HOST_TOOLS ON CACHE STRING "")
    set (CMAKE_CXX_STANDARD 17 CACHE STRING "")
    set (CMAKE_CXX_STANDARD_REQUIRED ON CACHE STRING "")
    set (CMAKE_CXX_EXTENSIONS OFF CACHE STRING "")
    set (CMAKE_POSITION_INDEPENDENT_CODE ON CACHE STRING "")
    set (CMAKE_CXX_VISIBILITY_PRESET hidden CACHE STRING "")
    set (CMAKE_OBJCXX_VISIBILITY_PRESET hidden CACHE STRING "")
    set (CMAKE_INTERPROCEDURAL_OPTIMIZATION ON CACHE STRING "")

    #[[
        - `CCP_PLATFORM` indicates the operating system a binary was built for
        - `CCP_ARCHITECTURE` indicates the hardware architecture a binary was built for
        - `CCP_TOOLSET` indicates the compiler (or toolset) a binary was built with
        - `CCP_VENDOR_LIB_PATH` is a convenience variable for find_package modules, to construct the default `lib` folder for a vendored SDK.
        - `CCP_VENDOR_BIN_PATH` is the same as CCP_VENDOR_LIB_PATH, but for the `bin` folder for a vendored SDK.

        See Platform Agnostic Developement section of the wiki:
        https://ccpgames.atlassian.net/wiki/spaces/PAD/overview?homepageId=171868162
    ]]
    set(CCP_PLATFORM "Linux" CACHE STRING "Target Platform")
    set(CCP_ARCHITECTURE "x64" CACHE STRING "Target Architecture")
    set(CCP_TOOLSET "GNU" CACHE STRING "Target Toolset")

    # adjust warning settings for all our projects, but do not treat them as errors just yet.
    add_compile_options(-Wall)
    # we want to use the two ones below once we're good with -Wall
    #    add_compile_options(-Wpedantic)
    #    add_compile_options(-Wextra)

    # Manually add debug symbols to builds
    add_compile_options(-g)

    # Enable fast, lossy math optimization while disabling optimizations for NaN/+-inf floating points
    # for details of ffast-math on AppleClang and GCC, consult the docs:
    # Clang https://clang.llvm.org/docs/UsersManual.html#cmdoption-ffast-math
    # GCC   https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html

    # Here, we attempt to match arm64-osx-carbon flags for macOS with the equivalent gcc flags:
    # AppleClang: -fhonor-infinities -fhonor-nans
    # GCC: -fno-finite-math-only

    #AppleClang: -ffp-model=fast
    # GCC: -funsafe-math-optimizations -fno-math-errno -ffp-contract=fast
    set(MATH_OPTIMIZE_FLAG -ffast-math -fno-finite-math-only -fsigned-zeros -ffp-contract=fast -fno-math-errno)
endif ()
