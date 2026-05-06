cmake_minimum_required(VERSION 3.16)
project(libnestegg LANGUAGES C)

add_library(nestegg STATIC
    src/nestegg.c
)

target_include_directories(
    nestegg PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(
    TARGETS nestegg
    EXPORT nesteggTargets
    CONFIGURATIONS ${CMAKE_CONFIGURATION_TYPES}
    ARCHIVE DESTINATION lib/
)

install(
    DIRECTORY include/ TYPE INCLUDE
)

install(
    EXPORT nesteggTargets
    DESTINATION share/libnestegg
    NAMESPACE Mozilla::
    FILE nesteggConfig.cmake
)