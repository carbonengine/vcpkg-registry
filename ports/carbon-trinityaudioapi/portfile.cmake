vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:carbonengine/trinityaudioapi.git
  REF b55268e6dd06cd7c275a22bc08b95d6b96982c48 #v99.99.96
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
