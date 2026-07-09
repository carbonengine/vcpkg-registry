# Copyright © 2025 CCP ehf.
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_PLATFORM_TOOLSET v145)
set(VCPKG_BUILD_TYPE "release")

set(VCPKG_CMAKE_SYSTEM_VERSION "10.0.26100.0")
set(VCPKG_CMAKE_CONFIGURE_OPTIONS -DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreadedDLL)

# Changes in vcpkg-tool (https://github.com/microsoft/vcpkg-tool/pull/1931) removed the ability to access the VCPKG_ROOT
# environment variable from inside the VCPKG build environment while VCPKG_LOAD_VCVARS_ENV is set to ON.
# For consistency, we have changed this for both windows & macos.
# More information available here: https://github.com/carbonengine/vcpkg-registry/pull/34
set(VCPKG_ENV_PASSTHROUGH_UNTRACKED PATH_TO_VCPKG_ROOT)
set(VCPKG_LOAD_VCVARS_ENV ON)

set(CARBON_BUILD_TYPE "Debug")

if (PORT MATCHES "carbon-.*")
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../toolchains/x64-windows-145-triplet.cmake")
    set(VCPKG_HASH_ADDITIONAL_FILES "${CMAKE_CURRENT_LIST_DIR}/../toolchains/x64-windows-145-carbon.cmake")
endif ()

if (PORT MATCHES "libyaml")
    set(VCPKG_LIBRARY_LINKAGE static)

    # Once we upgrade to libyaml-0.2.6 or above, we will no longer need this line
    # (currently 0.2.6 is only a release candidate and not yet available through VCPKG)
    set(VCPKG_CMAKE_CONFIGURE_OPTIONS "${VCPKG_CMAKE_CONFIGURE_OPTIONS};-DCMAKE_POLICY_VERSION_MINIMUM=3.5")
endif ()

if (PORT MATCHES "ccd")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "curl")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "openssl")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "protobuf")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "zlib")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "libuv")
    set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DBUILD_TESTING=OFF")
endif()

if (PORT MATCHES "carbon-pdmprotowrapper")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "meshoptimizer")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "tinyfiledialogs")
    set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_POLICY_VERSION_MINIMUM=3.5")
endif ()

if (PORT MATCHES "civetweb")
    set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_POLICY_VERSION_MINIMUM=3.5")
endif ()

if (PORT MATCHES "libjpeg-turbo")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "libsquish")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "libpng")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "freetype")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "brotli")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "bzip2")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "libogg")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "libvorbis")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "openvdb")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "boost-*")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "imath")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "blosc")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "lz4")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "zstd")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "libvpx")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()
