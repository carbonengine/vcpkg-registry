add_library(RadGameTools::Granny INTERFACE IMPORTED)

if(APPLE)
    target_compile_definitions(RadGameTools::Granny INTERFACE _MACOSX)
endif()

set(GRANNY_INCLUDE_ROOT "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/granny")

target_include_directories(RadGameTools::Granny INTERFACE
                                "${GRANNY_INCLUDE_ROOT}"
                                "${GRANNY_INCLUDE_ROOT}/gstate")


target_compile_definitions(RadGameTools::Granny INTERFACE BUILDING_GRANNY_STATIC)

set(GRANNY_LIB_ROOT "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib")

target_link_libraries(RadGameTools::Granny INTERFACE
                    "${GRANNY_LIB_ROOT}/${CMAKE_SHARED_LIBRARY_PREFIX}gstate_x64${CMAKE_STATIC_LIBRARY_SUFFIX}"
                    "${GRANNY_LIB_ROOT}/${CMAKE_SHARED_LIBRARY_PREFIX}granny2_static_x64${CMAKE_STATIC_LIBRARY_SUFFIX}")