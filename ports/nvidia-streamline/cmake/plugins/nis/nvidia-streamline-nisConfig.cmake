add_library(NVIDIA::Streamline::nis INTERFACE IMPORTED)

if(WIN32)
    set_target_properties(NVIDIA::Streamline::nis PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/nvidia-streamline"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/sl.nis.dll"
    )
endif()