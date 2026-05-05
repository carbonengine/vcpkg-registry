vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:intel/xess.git
  REF f03bde3a73b22a85b39d9bc90ccbfcec2b97d611 # TAG v2.0.1
  HEAD_REF master
)

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE.txt ${SOURCE_PATH}/third-party-programs.txt)

# Install Headers
file(COPY ${SOURCE_PATH}/inc/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Install Libs
file(COPY ${SOURCE_PATH}/lib/libxess.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

# Install Dlls
file(COPY ${SOURCE_PATH}/bin/libxess.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

# Share
file(COPY ${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})