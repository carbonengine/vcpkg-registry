vcpkg_from_git(
        OUT_SOURCE_PATH SOURCE_PATH
        URL git@github.com:carbonengine/resources.git
        REF b222a4c82af34e8411e8bc1f5b5e17dac3dde571
        HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS RESOURCES_FEATURE_OPTIONS
        FEATURES
        tests BUILD_TESTING
        docs  BUILD_DOCUMENTATION
)

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            ${RESOURCES_FEATURE_OPTIONS}
            -DVCPKG_USE_HOST_TOOLS=ON
            -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
            -DCMAKE_BUILD_TYPE=${CARBON_BUILD_TYPE}
            -DGTest_DIR=${VCPKG_INSTALLED_DIR}/${TARGET_TRIPLET}/share/gtest
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()