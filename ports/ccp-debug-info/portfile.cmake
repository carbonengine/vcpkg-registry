set(VCPKG_POLICY_HELPER_PORT enabled)

file(INSTALL
  "${CMAKE_CURRENT_LIST_DIR}/ccp_debug_info.cmake"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL
  "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

