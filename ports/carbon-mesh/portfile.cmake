vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:carbonengine/mesh.git
  REF de513eefdb095fcb04706b598df73c24b356895e
  HEAD_REF main
)
vcpkg_from_git(
  OUT_SOURCE_PATH UFBX_SOURCE_PATH
  URL git@github.com:ufbx/ufbx.git
  REF 448a7cc3ac0a323a870d118362830fb9936e586a
  HEAD_REF main
)
file(REMOVE_RECURSE "${SOURCE_PATH}/vendor/github.com/ufbx/ufbx")
file(RENAME 
    "${UFBX_SOURCE_PATH}" 
    "${SOURCE_PATH}/vendor/github.com/ufbx/ufbx"
)
vcpkg_from_git(
  OUT_SOURCE_PATH MOLTEN_VK_SOURCE_PATH
  URL git@github.com:KhronosGroup/MoltenVK.git
  REF f79c6c5690d3ee06ec3a00d11a8b1bab4aa1d030
  HEAD_REF main
)
file(REMOVE_RECURSE "${SOURCE_PATH}/vendor/github.com/moltenVK")
file(RENAME 
    "${MOLTEN_VK_SOURCE_PATH}" 
    "${SOURCE_PATH}/vendor/github.com/moltenVK"
)


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools                        BUILD_TOOLS
        simplygon	                         WITH_SIMPLYGON
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
  ${FEATURE_OPTIONS}
  -DVCPKG_USE_HOST_TOOLS=ON
  -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
  -DCMAKE_BUILD_TYPE=${CARBON_BUILD_TYPE}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
ccp_externalize_apple_debuginfo()
