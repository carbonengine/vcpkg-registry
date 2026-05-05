vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:GPUOpen-Effects/FidelityFX-CACAO.git
  REF 0ddca95e6714727a252ead345591ca8f2598f261 # TAG v1.2
  HEAD_REF master
)

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/license.txt)

# Install Headers
file(COPY ${SOURCE_PATH}/ffx-cacao/inc/ffx_cacao.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Install Source
file(COPY ${SOURCE_PATH}/ffx-cacao/src/ffx_cacao_defines.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/ffx-cacao/src/ffx_cacao.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/sample/src/Common/Common.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT}/CACAOCommon/)

# Share
file(COPY ${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})