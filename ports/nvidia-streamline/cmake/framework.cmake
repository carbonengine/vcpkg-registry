# Install Framework Headers
file(COPY ${SOURCE_PATH}/include/sl.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_appidentity.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_consts.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_core_api.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_core_types.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_device_wrappers.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_helpers.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_hooks.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_matrix_helpers.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_result.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_security.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_struct.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_template.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_version.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/include/sl_pcl.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Move Imgui to release path so it is picked up by cmake script and copied to bin destination
file(COPY ${SOURCE_PATH}/bin/x64/development/sl.imgui.dll DESTINATION ${SOURCE_PATH}/bin/x64)