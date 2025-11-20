vcpkg_from_git(
        OUT_SOURCE_PATH CERTIFY_SOURCE_DIR
        URL git@github.com:launchdarkly/certify
        REF 7116dd0e609ae44d037aa562736d3d59fce1b637
        HEAD_REF master
)

vcpkg_from_git(
        OUT_SOURCE_PATH TIMESTAMP_SOURCE_DIR
        URL git@github.com:chansen/c-timestamp
        REF b205c407ae6680d23d74359ac00444b80989792f
        HEAD_REF master
)

vcpkg_from_git(
        OUT_SOURCE_PATH TLEXPECTED_SOURCE_DIR
        URL git@github.com:TartanLlama/expected.git
        REF 292eff8bd8ee230a7df1d6a1c00c4ea0eb2f0362
        HEAD_REF master
)

vcpkg_from_git(
        OUT_SOURCE_PATH SOURCE_PATH
        URL git@github.com:launchdarkly/cpp-sdks.git
        REF 3e538d47d10a13c459f9bc5e79b2492848ce985c
        PATCHES
        fix-vcpkg-install.patch
)

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
        -DBUILD_TESTING=OFF
        -DVCPKG_USE_HOST_TOOLS=ON
        -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
        -DFETCHCONTENT_SOURCE_DIR_CERTIFY=${CERTIFY_SOURCE_DIR}
        -DFETCHCONTENT_SOURCE_DIR_TIMESTAMP=${TIMESTAMP_SOURCE_DIR}
        -DFETCHCONTENT_SOURCE_DIR_TL-EXPECTED=${TLEXPECTED_SOURCE_DIR}
        -DLD_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

ccp_externalize_apple_debuginfo()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")