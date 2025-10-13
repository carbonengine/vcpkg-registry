set(PATCHES
  patches/ConfigureInstallationRules.patch
)

vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:ccpgames/bsdiff-drake127.git
  REF 8f75c72d64cbca903eaa840d627fab207fdec406
  HEAD_REF master
  PATCHES ${PATCHES}
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
