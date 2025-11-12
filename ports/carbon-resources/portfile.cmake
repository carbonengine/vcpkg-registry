vcpkg_from_git(
        OUT_SOURCE_PATH SOURCE_PATH
        URL git@github.com:carbonengine/resources.git
        REF 1d19710f05e3662bf9b7af864b9bbce706abee1c
        HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS RESOURCES_FEATURE_OPTIONS
        FEATURES
        tests BUILD_TESTING
        docs  BUILD_DOCUMENTATION
)

set(EXTRA_OPTIONS "")
if("tests" IN_LIST FEATURES)
    list(APPEND EXTRA_OPTIONS -DGTest_DIR=${VCPKG_INSTALLED_DIR}/${TARGET_TRIPLET}/share/gtest)
endif()

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            ${RESOURCES_FEATURE_OPTIONS}
            -DVCPKG_USE_HOST_TOOLS=ON
            -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
            -DCMAKE_BUILD_TYPE=${CARBON_BUILD_TYPE}
            ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_install_copyright(
        FILE_LIST
        "${SOURCE_PATH}/LICENSE.txt"
        "${SOURCE_PATH}/NOTICE.md"
)

vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()