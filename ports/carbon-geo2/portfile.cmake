vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:carbonengine/geo2.git
  REF 3165fce11bc818ca469f14b15ca496087fafdaa6
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
