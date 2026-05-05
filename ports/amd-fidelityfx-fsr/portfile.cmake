vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:GPUOpen-Effects/FidelityFX-FSR.git
  REF a21ffb8f6c13233ba336352bdff293894c706575 # TAG v1.0.2
  HEAD_REF master
)

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/license.txt)

# Install Headers
file(COPY ${SOURCE_PATH}/ffx-fsr/ffx_a.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/ffx-fsr/ffx_fsr1.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Share
file(COPY ${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})