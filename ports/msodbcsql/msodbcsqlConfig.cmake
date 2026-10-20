if(WIN32)
    add_library(msodbcsql STATIC IMPORTED)
    set_target_properties(msodbcsql PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/msodbcsql18.lib"
    )
elseif (APPLE)
    add_library(msodbcsql SHARED IMPORTED)
    set_target_properties(msodbcsql PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/libmsodbcsql.18.dylib"
    )
endif ()
