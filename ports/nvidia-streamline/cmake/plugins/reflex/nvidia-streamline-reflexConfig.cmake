add_library(NVIDIA::Streamline::reflex INTERFACE IMPORTED)

if(WIN32)
    set_target_properties(NVIDIA::Streamline::reflex PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/nvidia-streamline"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/sl.reflex.dlll"
    )
endif()