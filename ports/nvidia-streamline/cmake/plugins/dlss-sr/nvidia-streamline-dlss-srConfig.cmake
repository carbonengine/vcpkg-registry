add_library(NVIDIA::Streamline::dlss-sr::base INTERFACE IMPORTED)

if(WIN32)
    set_target_properties(NVIDIA::Streamline::dlss-sr::base PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/nvidia-streamline"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/nvngx_dlss.dll"
    )
endif()

add_library(NVIDIA::Streamline::dlss-sr::sl INTERFACE IMPORTED)

if(WIN32)
    set_target_properties(NVIDIA::Streamline::dlss-sr::sl PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/nvidia-streamline"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/sl.dlss.dll"
    )
endif()

# Framework
add_library(NVIDIA::Streamline::dlss-sr INTERFACE IMPORTED)

target_link_libraries(NVIDIA::Streamline::dlss-sr INTERFACE NVIDIA::Streamline::dlss-sr::base NVIDIA::Streamline::dlss-sr::sl)