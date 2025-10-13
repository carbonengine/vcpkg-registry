if (VCPKG_TARGET_IS_WINDOWS)
    set(DIST_URL "https://github.com/ccpgames/cpython/releases/download/v3.12.3/python-3.12.3.0+ccp-customizations_WINDOWS_V141.zip")
    set(SHA512 a91fb51f84b5798d6a25be6bc0e7351d8007a3f6a4f91d609498848b1cdf76b52dea316b465b281df7d2f2b60553d0d9216e863bb486e5f553a24a53e34ae6d2)
elseif (VCPKG_TARGET_IS_OSX)
    set(DIST_URL "https://github.com/ccpgames/cpython/releases/download/v3.12.3/python-3.12.3.0+ccp-customizations_MACOS_UNIVERSAL.zip")
    set(SHA512 a749941b07935c52a6743c0e5e7210c256b08b70a913904ba2febf0cddc9fb6e234cdc969fd3ebd6e1b343756b18b6270dffb98b9f0e2f39fb5c92659cc9bb78)
endif()

string(REGEX MATCH "^([0-9]+)\\.([0-9]+)\\.([0-9]+)" PYTHON_VERSION "${VERSION}")
set(PYTHON_VERSION_MAJOR "${CMAKE_MATCH_1}")
set(PYTHON_VERSION_MINOR "${CMAKE_MATCH_2}")
set(PYTHON_VERSION_PATCH "${CMAKE_MATCH_3}")

vcpkg_download_distfile(
    ZIP_LOC
    URLS ${DIST_URL}
    FILENAME python312_prebuild
    SHA512 ${SHA512}
)

vcpkg_extract_source_archive(
    SOURCE_DIR
    ARCHIVE ${ZIP_LOC}
    NO_REMOVE_ONE_LEVEL
)

function(_generate_finder)
    cmake_parse_arguments(PythonFinder "NO_OVERRIDE" "DIRECTORY;PREFIX" "" ${ARGN})
    configure_file(
            "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
            "${CURRENT_PACKAGES_DIR}/share/${PythonFinder_DIRECTORY}/vcpkg-cmake-wrapper.cmake"
            @ONLY
    )
endfunction()

# Generate wrappers which overwrite FindPython behavior
_generate_finder(DIRECTORY "python3" PREFIX "Python3")
_generate_finder(DIRECTORY "python" PREFIX "Python")

if(VCPKG_TARGET_IS_WINDOWS)
    # Extract standard library
    vcpkg_extract_archive(
        ARCHIVE ${SOURCE_DIR}/bin/Windows/x64/${VCPKG_PLATFORM_TOOLSET}/Python312.zip
        DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/Lib
    )

    file(GLOB PYTHON_EXTENSIONS LIST_DIRECTORIES false "${SOURCE_DIR}/bin/Windows/x64/${VCPKG_PLATFORM_TOOLSET}/*.pyd")
    file(GLOB DLL_FILES LIST_DIRECTORIES false "${SOURCE_DIR}/bin/Windows/x64/${VCPKG_PLATFORM_TOOLSET}/*.dll")
    file(GLOB LIB_FILES LIST_DIRECTORIES false "${SOURCE_DIR}/lib/Windows/x64/${VCPKG_PLATFORM_TOOLSET}/*.lib")

    file(COPY ${DLL_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${LIB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${PYTHON_EXTENSIONS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${PYTHON_EXTENSIONS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/DLLs)
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/DLLs")

    vcpkg_copy_tools(
            TOOL_NAMES
            python
            pythonw
            venvlauncher
            venvwlauncher
            SEARCH_DIR
            ${SOURCE_DIR}/bin/Windows/x64/${VCPKG_PLATFORM_TOOLSET}
            AUTO_CLEAN
    )

    file(COPY "${SOURCE_DIR}/Include/"
            DESTINATION "${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}"
            FILES_MATCHING PATTERN *.h
    )
elseif(VCPKG_TARGET_IS_OSX)
    # Extract standard library archive
    vcpkg_extract_archive(
            ARCHIVE ${SOURCE_DIR}/bin/macOS/universal/AppleClang/Python312.zip
            DESTINATION ${CURRENT_PACKAGES_DIR}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}
    )

    # The FindPython module expects the standard library to be located directly under ´lib/python´
    # whereas the direct output of the archive extraction above will be ´lib/python/Lib
    file(COPY ${CURRENT_PACKAGES_DIR}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/Lib/
            DESTINATION ${CURRENT_PACKAGES_DIR}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/
    )
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/Lib)

    file(GLOB DYNAMIC_LIBRARIES LIST_DIRECTORIES false "${SOURCE_DIR}/bin/macOS/universal/AppleClang/*.dylib")
    file(COPY ${DYNAMIC_LIBRARIES} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

    file(GLOB PYTHON_EXECUTABLE LIST_DIRECTORIES false "${SOURCE_DIR}/bin/macOS/universal/AppleClang/*.exe")
    file(COPY ${PYTHON_EXECUTABLE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    # .exe suffix breaks CMAKE find_program utility on macOS
    file(RENAME ${CURRENT_PACKAGES_DIR}/tools/${PORT}/python.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/python)

    file(COPY "${SOURCE_DIR}/Include/"
            DESTINATION "${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}"
            FILES_MATCHING PATTERN *.h
    )

    # macOS python distributions expect shared libraries to be located under /lib/pythonX.X/lib-dynload
    file(COPY ${SOURCE_DIR}/bin/macOS/universal/AppleClang/
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/lib-dynload
        FILES_MATCHING PATTERN *.so
    )
else()
    message(FATAL_ERROR "Unsupported platform")
endif()