vcpkg_download_distfile(
    ZIP_LOC
    URLS "https://vcpkg-prebuilt-sdks.ccpgames.com/3dxwaresdk/3dxwaresdk-v10.7.0-osx.zip"
    FILENAME 3dxwaresdk
    SHA512 89783ea87782304373d5671a026f8d16e2f235d7b82ff906670b1e743ac233daf99a054a68207c6116e45f54e805924376fd896ca6642dcf394599b58b9a935a
)

vcpkg_extract_source_archive(
    SOURCE_DIR
    ARCHIVE ${ZIP_LOC}
)

file(COPY ${SOURCE_DIR}/lib DESTINATION ${CURRENT_PACKAGES_DIR})
file(COPY ${SOURCE_DIR}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(COPY ${SOURCE_DIR}/share DESTINATION ${CURRENT_PACKAGES_DIR})
