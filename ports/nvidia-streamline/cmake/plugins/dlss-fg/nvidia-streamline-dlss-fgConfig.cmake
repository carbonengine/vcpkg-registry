add_library(NVIDIA::Streamline::dlss-fg::base INTERFACE IMPORTED)

if(WIN32)
    set_target_properties(NVIDIA::Streamline::dlss-fg::base PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/nvidia-streamline"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/nvngx_dlssg.dll"
    )
endif()

add_library(NVIDIA::Streamline::dlss-fg::sl INTERFACE IMPORTED)

if(WIN32)
    set_target_properties(NVIDIA::Streamline::dlss-fg::sl PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/nvidia-streamline"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/sl.dlss_g.dll"
    )
endif()

# Framework
add_library(NVIDIA::Streamline::dlss-fg INTERFACE IMPORTED)

target_link_libraries(NVIDIA::Streamline::dlss-fg INTERFACE NVIDIA::Streamline::dlss-fg::base NVIDIA::Streamline::dlss-fg::sl)