set(DIST_URL "https://github.com/NVIDIA-RTX/Streamline/releases/download/v2.8.0/streamline-sdk-v2.8.0.zip")
set(SHA512 "7119d80495ae53db754c3edb4d9e5e580a1647c056a8c5b372215c4ff10e3787855b75719590f74e3137fd552cc3f38e2a00d00fb13be256b6ba4b0b26c41c68")

set(PATCHES
  patches/add-cmake-min-version.patch
)

vcpkg_download_distfile(
    ZIP_LOC
    URLS ${DIST_URL}
    FILENAME streamline
    SHA512 ${SHA512}
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ZIP_LOC}
    NO_REMOVE_ONE_LEVEL
    PATCHES ${PATCHES}
)

# Install Framework Headers
include(${CMAKE_CURRENT_LIST_DIR}/cmake/framework.cmake)

# Setup the features
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dlss-sr                     STREAMLINE_FEATURE_DLSS_SR
        dlss-fg                     STREAMLINE_FEATURE_DLSS_FG
        nis	                        STREAMLINE_FEATURE_NIS
        reflex                      STREAMLINE_FEATURE_REFLEX
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${SOURCE_PATH}/out
    -DSTREAMLINE_SDK_ROOT=${SOURCE_PATH}
    -DSTREAMLINE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/bin
    -DSTREAMLINE_FEATURE_IMGUI=ON
    ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/license.txt ${SOURCE_PATH}/3rd-party-licenses.md)

vcpkg_cmake_config_fixup()

# Share
file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake/${PORT}Config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Plugins
if ("dlss-sr" IN_LIST FEATURES)
  include(${CMAKE_CURRENT_LIST_DIR}/cmake/plugins/dlss-sr/dlss-sr.cmake)
endif()

if ("dlss-fg" IN_LIST FEATURES)
  include(${CMAKE_CURRENT_LIST_DIR}/cmake/plugins/dlss-fg/dlss-fg.cmake)
endif()

if ("nis" IN_LIST FEATURES)
  include(${CMAKE_CURRENT_LIST_DIR}/cmake/plugins/nis/nis.cmake)
endif()

if ("reflex" IN_LIST FEATURES)
  include(${CMAKE_CURRENT_LIST_DIR}/cmake/plugins/reflex/reflex.cmake)
endif()

# Create usage file
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage.in ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)