# Toolset folders bundled inside the SDK zips on S3.

set(WWISE_WINDOWS_TOOLSET "x64_vc170")
set(WWISE_OSX_TOOLSET     "Mac_Xcode1600")

if(VCPKG_TARGET_IS_WINDOWS)
    set(DIST_URL "https://vcpkg-prebuilt-sdks.ccpgames.com/wwise/wwise-v${VERSION}-windows.zip")
    set(SHA512 1c65cbd2f27545a827994ce2023e7630fc8a9907bead382c1fd408fafec2e763e70439138918fc9dcb3334e4133d6cba5b3dd36a56ca88a5f1b247b32b518211)
    set(WWISE_PLATFORM_SUBDIR "${WWISE_WINDOWS_TOOLSET}")
elseif(VCPKG_TARGET_IS_OSX)
    set(DIST_URL "https://vcpkg-prebuilt-sdks.ccpgames.com/wwise/wwise-v${VERSION}-osx.zip")
    set(SHA512 f155d5db106c313db39b39519a04705c698abdb8fb1aedf22a6238380a211085df23deff515ac493cbce39dcad62da32955f58c2aaf37c492ea98fe9a196329d)
    set(WWISE_PLATFORM_SUBDIR "${WWISE_OSX_TOOLSET}")
else()
    message(FATAL_ERROR "wwise port supports Windows and macOS only")
endif()

vcpkg_download_distfile(
    ZIP_LOC
    URLS ${DIST_URL}
    FILENAME "wwise-v${VERSION}-${VCPKG_TARGET_TRIPLET}.zip"
    SHA512 ${SHA512}
)

vcpkg_extract_source_archive(
    SOURCE_DIR
    ARCHIVE ${ZIP_LOC}
    NO_REMOVE_ONE_LEVEL
)

set(WWISE_PLATFORM_DIR "${SOURCE_DIR}/${WWISE_PLATFORM_SUBDIR}")

# Headers
file(COPY "${SOURCE_DIR}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Release
file(COPY "${WWISE_PLATFORM_DIR}/Release/lib/" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
if(EXISTS "${WWISE_PLATFORM_DIR}/Release/bin")
    file(COPY "${WWISE_PLATFORM_DIR}/Release/bin/" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()

# Profile
file(COPY "${WWISE_PLATFORM_DIR}/Profile/lib/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
if(EXISTS "${WWISE_PLATFORM_DIR}/Profile/bin")
    file(COPY "${WWISE_PLATFORM_DIR}/Profile/bin/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/WwiseConfig.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/wwise"
)
