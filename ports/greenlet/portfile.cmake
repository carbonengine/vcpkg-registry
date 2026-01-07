set(PATCHES
  patches/delete_setup_py.patch
  patches/fix_test_extention_importing.patch
  patches/non_local_greenlet_import.patch
  patches/tests_remove_dir_local_imports.patch
)

vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:ccpgames/greenlet.git
  REF ea4bc2776c75429a577e539389fee40ad9e46707 # TAG 3.0.3
  HEAD_REF master
  PATCHES ${PATCHES}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH}/)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/greenletConfig.cmake DESTINATION ${SOURCE_PATH}/)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

set(BUILD_PATHS
  "${CURRENT_PACKAGES_DIR}/bin/*.dll"
  "${CURRENT_PACKAGES_DIR}/debug/bin/*.dll"
  "${CURRENT_PACKAGES_DIR}/bin/*.pyd"
  "${CURRENT_PACKAGES_DIR}/debug/bin/*.pyd"
)
vcpkg_copy_pdbs(
  BUILD_PATHS ${BUILD_PATHS}
)
ccp_externalize_apple_debuginfo()
