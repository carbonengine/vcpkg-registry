set(DIST_URL "https://developer.nvidia.com/rdp/assets/nsight-aftermath-sdk-2021_1-windows-package")
set(SHA512 "68e4297b0327d5bf51b8ddc3a5fdcb6a1f919075f31f0076e675718b16115f1cf1ec25447f7abc5d0a3dea041f2881a3c6a1bed883f9618124c3a9f757f1483f")

vcpkg_download_distfile(
    ZIP_LOC
    URLS ${DIST_URL}
    FILENAME aftermath
    SHA512 ${SHA512}
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ZIP_LOC}
    NO_REMOVE_ONE_LEVEL
)

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)

# Install Headers
file(COPY ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Install Libs
file(COPY ${SOURCE_PATH}/lib/x64/GFSDK_Aftermath_Lib.x64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

# Install DLLS
file(COPY ${SOURCE_PATH}/lib/x64/GFSDK_Aftermath_Lib.x64.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

# Share
file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake/${PORT}Config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})