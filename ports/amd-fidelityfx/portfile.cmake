set(DIST_URL "https://github.com/GPUOpen-LibrariesAndSDKs/FidelityFX-SDK/releases/download/v1.1.4/FidelityFX-SDK-v1.1.4.zip")
set(SHA512 "3f309d5d12374e4a727c635b10529540712f93b870f77e79952245e0a92b18e518cd412edd1fde45156bfa9d7e70b5f6dc79828d2cc9e13c6b00296d8eedcec2")

vcpkg_download_distfile(
    ZIP_LOC
    URLS ${DIST_URL}
    FILENAME fidelityfx
    SHA512 ${SHA512}
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ZIP_LOC}
    NO_REMOVE_ONE_LEVEL
)

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/sdk/LICENSE.txt)

# Install Framework Headers
file(COPY ${SOURCE_PATH}/ffx-api/include/ffx_api DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Install Framework Libs
file(COPY ${SOURCE_PATH}/PrebuiltSignedDLL/amd_fidelityfx_dx12.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

# Install Framework DLLS
file(COPY ${SOURCE_PATH}/PrebuiltSignedDLL/amd_fidelityfx_dx12.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

# Share
file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake/${PORT}Config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})