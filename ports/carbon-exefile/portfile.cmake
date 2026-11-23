set(OSX_ADJUST_RPATH_MANUALLY FALSE)

if(TARGET_TRIPLET MATCHES ".*universal-osx.*")
    set(configuration_err_msg "VCPKG does not support adjusting the rpath of universal binary executables. You MUST set VCPKG_FIXUP_MACHO_RPATH to OFF in your triplet file.")
    if(NOT DEFINED VCPKG_FIXUP_MACHO_RPATH)
      message(FATAL_ERROR ${configuration_err_msg})
    elseif(VCPKG_FIXUP_MACHO_RPATH)
      message(FATAL_ERROR ${configuration_err_msg})
    endif()
    find_program(INSTALL_NAME_TOOL_COMMAND install_name_tool REQUIRED)
    set(OSX_ADJUST_RPATH_MANUALLY TRUE)
endif()

vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL https://github.com/carbonengine/exefile.git
  REF 70a7e72ca4d5f6d1fb1d0424999875b7d6f5e29c
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DCMAKE_BUILD_TYPE=${CARBON_BUILD_TYPE}
)

vcpkg_cmake_install()

set(BUILD_PATHS
        "${CURRENT_PACKAGES_DIR}/bin/*.exe"
        "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe"
)
vcpkg_copy_pdbs(BUILD_PATHS ${BUILD_PATHS})
ccp_externalize_apple_debuginfo()

set(EXEFILE_TOOL exefile)

if (DEFINED CARBON_BUILD_TYPE AND NOT CARBON_BUILD_TYPE MATCHES "Release")
  # exefile's per-config postfixes are lower case (e.g. exefile_debug), which matters on case-sensitive file systems
  string(TOLOWER "${CARBON_BUILD_TYPE}" CARBON_BUILD_TYPE_LOWER)
  set(EXEFILE_TOOL ${EXEFILE_TOOL}_${CARBON_BUILD_TYPE_LOWER})
endif()

vcpkg_copy_tools(
  TOOL_NAMES ${EXEFILE_TOOL}
  AUTO_CLEAN
)

if (OSX_ADJUST_RPATH_MANUALLY)
  # we must manually do here, what vcpkg fails to do it'self. VCPKG fails to adjust RPATHS correctly for universal executable files
  # -add_rpath @loader_path/../../lib adds the VCPKG lib folder as an rpath
  # -delete_rpath @executable_path/. removes the executable local directory
  vcpkg_execute_required_process(
    COMMAND ${INSTALL_NAME_TOOL_COMMAND} -delete_rpath "\@executable_path/." "${EXEFILE_TOOL}" 
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    LOGNAME "deleterpath"
    SAVE_LOG_FILES
  )
  vcpkg_execute_required_process(
    COMMAND ${INSTALL_NAME_TOOL_COMMAND} -add_rpath "\@loader_path/../../lib" "${EXEFILE_TOOL}"
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    LOGNAME "addrpath"
    SAVE_LOG_FILES
  )
endif()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
