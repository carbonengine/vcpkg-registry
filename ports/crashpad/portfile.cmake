vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Original version of crashpad that this adapted portfile was checking out 9a31d3f8e9815774026a753a1ff6155347cd549f
vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/crashpad/crashpad
    REF db9863a2177a2b3d329bc31fb307302b80b00dd0
    PATCHES
        dot_gn_python_exe.patch
)



vcpkg_find_acquire_program(PYTHON3)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON3}\"")

function(checkout_in_path PATH URL REF)
    set(options "")
    set(single_value_keywords "")
    set(multi_value_keywords "PATCHES")
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
            "${options}" "${single_value_keywords}" "${multi_value_keywords}"
    )

    if(EXISTS "${PATH}")
        return()
    endif()
    
    vcpkg_from_git(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        URL "${URL}"
        REF "${REF}"
        PATCHES ${arg_PATCHES}
    )
    file(RENAME "${DEP_SOURCE_PATH}" "${PATH}")
    file(REMOVE_RECURSE "${DEP_SOURCE_PATH}")
endfunction()

# Original version of mini_chromium that this adapted portfile was checkingt out c426ff98e1d9e9d59777fe8b883a5c0ceeca9ca3
checkout_in_path(
    "${SOURCE_PATH}/third_party/mini_chromium/mini_chromium"
    "https://chromium.googlesource.com/chromium/mini_chromium"
    "329ca82f73a592d832e79334bed842fba85b9fdd"
    PATCHES 
        2to3_win_helper_py.patch
        2to3_find_mac_sdk_py.patch
)

function(replace_gn_dependency INPUT_FILE OUTPUT_FILE LIBRARY_NAMES)
    unset(_LIBRARY_DEB CACHE)
    find_library(_LIBRARY_DEB NAMES ${LIBRARY_NAMES}
        PATHS "${CURRENT_INSTALLED_DIR}/debug/lib"
        NO_DEFAULT_PATH)

    if(_LIBRARY_DEB MATCHES "-NOTFOUND")
        message(WARNING "Could not find debug library with names: ${LIBRARY_NAMES}")
    endif()

    unset(_LIBRARY_REL CACHE)
    find_library(_LIBRARY_REL NAMES ${LIBRARY_NAMES}
        PATHS "${CURRENT_INSTALLED_DIR}/lib"
        NO_DEFAULT_PATH)

    if(_LIBRARY_REL MATCHES "-NOTFOUND")
        message(WARNING "Could not find library with names: ${LIBRARY_NAMES}")
    endif()

    set(_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include")

    file(REMOVE "${OUTPUT_FILE}")
    configure_file("${INPUT_FILE}" "${OUTPUT_FILE}" @ONLY)
endfunction()

replace_gn_dependency(
    "${CMAKE_CURRENT_LIST_DIR}/zlib.gn"
    "${SOURCE_PATH}/third_party/zlib/BUILD.gn"
    "z;zlib;zlibd"
)

set(OPTIONS_DBG "is_debug=true")
set(OPTIONS_REL "")

if(CMAKE_HOST_WIN32)
    # Load toolchains
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
    endif()
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")

    foreach(_VAR CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS
        CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE)
        string(STRIP "${${_VAR}}" ${_VAR})
    endforeach()

    set(OPTIONS_DBG "${OPTIONS_DBG} \
        extra_cflags_c=\"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG}\" \
        extra_cflags_cc=\"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}\"")

    set(OPTIONS_REL "${OPTIONS_REL} \
        extra_cflags_c=\"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}\" \
        extra_cflags_cc=\"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}\"")

    set(DISABLE_WHOLE_PROGRAM_OPTIMIZATION "\
        extra_cflags=\"/GL-\" \
        extra_ldflags=\"/LTCG:OFF\" \
        extra_arflags=\"/LTCG:OFF\"")

    set(OPTIONS_DBG "${OPTIONS_DBG} ${DISABLE_WHOLE_PROGRAM_OPTIMIZATION}")
    set(OPTIONS_REL "${OPTIONS_REL} ${DISABLE_WHOLE_PROGRAM_OPTIMIZATION}")
endif()

if (VCPKG_TARGET_IS_OSX)
    # check whether we want to build a universal binary
    list(FIND VCPKG_TARGET_ARCHITECTURE arm64 FOUND_ARM64)
    list(FIND VCPKG_TARGET_ARCHITECTURE x86_64 FOUND_X64)

    if (FOUND_X64 GREATER -1 AND FOUND_ARM64 GREATER -1)
        set(OPTIONS_DBG "${OPTIONS_DBG} target_cpu=\"mac_universal\"")
        set(OPTIONS_REL "${OPTIONS_REL} target_cpu=\"mac_universal\"")
    endif()
endif()

vcpkg_gn_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

set(CRASHPAD_TARGETS client util third_party/mini_chromium/mini_chromium/base handler:crashpad_handler)

if (VCPKG_TARGET_IS_OSX)
    list(APPEND CRASHPAD_TARGETS util:mig_output)
endif()

vcpkg_gn_install(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS ${CRASHPAD_TARGETS}
)

message(STATUS "Installing headers...")
set(PACKAGES_INCLUDE_DIR "${CURRENT_PACKAGES_DIR}/include/${PORT}")
function(install_headers DIR)
    file(COPY "${DIR}" DESTINATION "${PACKAGES_INCLUDE_DIR}" FILES_MATCHING PATTERN "*.h")
endfunction()
install_headers("${SOURCE_PATH}/client")
install_headers("${SOURCE_PATH}/util")
install_headers("${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/base")
install_headers("${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/build")

file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen/build/chromeos_buildflags.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}/build")

# remove empty directories
file(REMOVE_RECURSE 
    "${PACKAGES_INCLUDE_DIR}/util/net/testdata" 
    "${PACKAGES_INCLUDE_DIR}/build/ios")

configure_file("${CMAKE_CURRENT_LIST_DIR}/crashpadConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/crashpadConfig.cmake" @ONLY)

vcpkg_copy_pdbs()
file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)
