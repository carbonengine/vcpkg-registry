# Headers
file(COPY ${SOURCE_PATH}/include/sl_reflex.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Share
file(COPY ${CMAKE_CURRENT_LIST_DIR}/${PORT}-reflexConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}-reflex)

# Usage
string(APPEND PLUGIN-USAGE "\n    find_package(nvidia-streamline-reflex REQUIRED)\n    target_link_libraries(main PRIVATE NVIDIA::Streamline::reflex\n")