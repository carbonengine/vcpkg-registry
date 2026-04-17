vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:carbonengine/exefileconsole.git
  REF 6083e3e0d0338aa3aaf0325f315411d49978ee3c
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DCMAKE_BUILD_TYPE=${CARBON_BUILD_TYPE}
)

vcpkg_cmake_install()

set(EXEFILECONSOLE_TOOL ExeFileConsole)

if (DEFINED CARBON_BUILD_TYPE AND NOT CARBON_BUILD_TYPE MATCHES "Release")
  set(EXEFILECONSOLE_TOOL ${EXEFILECONSOLE_TOOL}_${CARBON_BUILD_TYPE})
endif()

vcpkg_copy_tools(
  TOOL_NAMES ${EXEFILECONSOLE_TOOL}
  AUTO_CLEAN
)

vcpkg_copy_pdbs()
ccp_externalize_apple_debuginfo()
