vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:GPUOpen-Effects/FidelityFX-CAS.git
  REF d70012e4afff58e907b0201aac041c8a2679590d # TAG v1.0
  HEAD_REF master
)

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE.txt)

# Install Headers
file(COPY ${SOURCE_PATH}/ffx-cas/ffx_a.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/ffx-cas/ffx_cas.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Share
file(COPY ${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})