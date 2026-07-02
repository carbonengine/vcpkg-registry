vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:carbonengine/imagetools.git
  REF 6b9b1281014bb95c35c2b8ff37f67ed8c0d3f6f1
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DBUILD_TESTING=OFF
    -DVCPKG_USE_HOST_TOOLS=ON
    -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
    -DCMAKE_BUILD_TYPE=${CARBON_BUILD_TYPE}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
set(BUILD_PATHS
  "${CURRENT_PACKAGES_DIR}/bin/*.pyd"
  "${CURRENT_PACKAGES_DIR}/debug/bin/*.pyd"
)
vcpkg_copy_pdbs(BUILD_PATHS ${BUILD_PATHS})
ccp_externalize_apple_debuginfo()

vcpkg_install_copyright(
  FILE_LIST
    "${SOURCE_PATH}/LICENSE.md"
)
