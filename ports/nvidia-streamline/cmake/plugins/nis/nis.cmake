# Headers
file(COPY ${SOURCE_PATH}/include/sl_nis.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Share
file(COPY ${CMAKE_CURRENT_LIST_DIR}/${PORT}-nisConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}-nis)

# Usage
string(APPEND PLUGIN-USAGE "\n    find_package(nvidia-streamline-nis REQUIRED)\n    target_link_libraries(main PRIVATE NVIDIA::Streamline::nis\n")