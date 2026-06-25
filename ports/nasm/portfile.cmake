set(NASM_VERSION "3.01")

set(DIST_URLS
    "https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/macosx/nasm-${NASM_VERSION}-macosx.zip"
    "https://www.nasm.dev/pub/nasm/releasebuilds/${NASM_VERSION}/macosx/nasm-${NASM_VERSION}-macosx.zip"
)

set(SHA512 "1d38da1e8c8c033deea85ecec6b9fcfc4c48503307411316d4dac0a27f6955dcfc9a8f97130312e97c36690ecf3a1263c819163283e45409fe0bfa9dc4a5833d")

vcpkg_download_distfile(
    ZIP_LOC
    URLS ${DIST_URLS}
    FILENAME nasm
    SHA512 ${SHA512}
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ZIP_LOC}
    NO_REMOVE_ONE_LEVEL
)

# Copy tool
file(COPY ${SOURCE_PATH}/nasm-${NASM_VERSION}/nasm DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})

# Usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})