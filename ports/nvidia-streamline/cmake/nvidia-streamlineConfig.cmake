# Common
add_library(NVIDIA::Streamline::common INTERFACE IMPORTED)

if(WIN32)
    set_target_properties(NVIDIA::Streamline::common PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/nvidia-streamline"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/sl.common.dll"
    )
endif()

# Interposer
add_library(NVIDIA::Streamline::interposer INTERFACE IMPORTED)

if(WIN32)
    set_target_properties(NVIDIA::Streamline::interposer PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/nvidia-streamline"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/sl.interposer.dll"
    )
endif()

add_library(NVIDIA::Streamline::pcl INTERFACE IMPORTED)

if(WIN32)
    set_target_properties(NVIDIA::Streamline::pcl PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/nvidia-streamline"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/sl.pcl.dll"
    )
endif()

add_library(NVIDIA::Streamline::imgui INTERFACE IMPORTED)

if(WIN32)
    set_target_properties(NVIDIA::Streamline::imgui PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/nvidia-streamline"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/sl.imgui.dll"
    )
endif()

# Framework
add_library(NVIDIA::Streamline INTERFACE IMPORTED)

target_link_libraries(NVIDIA::Streamline INTERFACE NVIDIA::Streamline::common NVIDIA::Streamline::interposer NVIDIA::Streamline::pcl NVIDIA::Streamline::imgui)