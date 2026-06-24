set(DIST_URL "https://vcpkg-prebuilt-sdks.ccpgames.com/fxc/fxc-v${VERSION}.zip")
set(SHA512 "27f7d942c6a4007576756521e965cf35ab0fae7ba7e05ef563f3dc9b41464238cdfaaa0133a9905cbfb8c066a4f449ec3bcefaff3d5e9943507eb19755b6d5db")

vcpkg_download_distfile(
    ZIP_LOC
    URLS ${DIST_URL}
    FILENAME fxc
    SHA512 ${SHA512}
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ZIP_LOC}
    NO_REMOVE_ONE_LEVEL
    PATCHES ${PATCHES}
)

# Copy tool
file(COPY ${SOURCE_PATH}/fxc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(COPY ${SOURCE_PATH}/D3dCompiler_47.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

# Usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})