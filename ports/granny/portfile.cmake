set(DIST_URL "https://vcpkg-prebuilt-sdks.ccpgames.com/granny/granny-v${VERSION}.zip")
set(SHA512 "2c46f9ba28caa1d35abebbede37141af6e82e53da0d146cb1ea99282a2c0b19d57c1582ad70f6e37bb5b56daac4ad924f1142ce39dc5057b3bf7de93c9a6c9b6")

vcpkg_download_distfile(
    ZIP_LOC
    URLS ${DIST_URL}
    FILENAME granny
    SHA512 ${SHA512}
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ZIP_LOC}
    NO_REMOVE_ONE_LEVEL
    PATCHES ${PATCHES}
)

# Install Headers
file(COPY ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Install Libs
if(WIN32)

  file(COPY ${SOURCE_PATH}/lib/Windows/x64/v141/gstate_x64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(COPY ${SOURCE_PATH}/lib/Windows/x64/v141/granny2_static_x64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

elseif(APPLE)

  file(COPY ${SOURCE_PATH}/lib/macOS/universal/AppleClang/libgranny2_static_x64.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(COPY ${SOURCE_PATH}/lib/macOS/universal/AppleClang/libgstate_x64.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

endif()

# Share
file(COPY ${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})