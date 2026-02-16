add_library(Greenlet INTERFACE IMPORTED)

set(Greenlet_INCLUDE_DIR "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include")
set(Greenlet_VERSION "3.0.3")
set(Greenlet_Libraries _greenlet)

if(APPLE)
    set(_SHARED_LIBRARY_SUFFIX ".so")
else()
    set(_SHARED_LIBRARY_SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX})
endif()

if(APPLE)
    set_target_properties(Greenlet PROPERTIES
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/_greenlet.so"
    )
elseif(WIN32)
    set_target_properties(Greenlet PROPERTIES
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/_greenlet.pyd"
    )
else()
    message(FATAL_ERROR "Greenlet not supported on platform.")
endif()

define_property(TARGET PROPERTY PYTHON_MODULE_DIR BRIEF_DOCS "path to the python module")

set_target_properties(Greenlet PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Greenlet_INCLUDE_DIR}"
    INTERFACE_LINK_LIBRARIES ${Greenlet_Libraries}
    PYTHON_MODULE_DIR "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/python"
)
