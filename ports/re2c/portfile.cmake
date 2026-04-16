vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skvadrik/re2c
    REF refs/tags/2.2
    SHA512 59121c599a36b753dd4f306fbf1d9b2a7fadaa8baa88cf0b6b144716fd75ce2884ab45f5a42d8ae5f42a00ceb8c0d9fc5ff9a60125efc58f21231e8c021993bb
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")