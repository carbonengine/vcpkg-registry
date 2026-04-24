# Headers
file(COPY ${SOURCE_PATH}/include/sl_dlss_g.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Share
file(COPY ${CMAKE_CURRENT_LIST_DIR}/${PORT}-dlss-fgConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}-dlss-fg)

# Usage
string(APPEND PLUGIN-USAGE "\n    find_package(nvidia-streamline-dlss-fg REQUIRED)\n    target_link_libraries(main PRIVATE NVIDIA::Streamline::dlss-fg\n")


