 # Headers
file(COPY ${SOURCE_PATH}/include/sl_dlss.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Share
file(COPY ${CMAKE_CURRENT_LIST_DIR}/${PORT}-dlss-srConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}-dlss-sr)

# Usage
string(APPEND PLUGIN-USAGE "\n    find_package(nvidia-streamline-dlss-sr REQUIRED)\n    target_link_libraries(main PRIVATE NVIDIA::Streamline::dlss-sr\n")