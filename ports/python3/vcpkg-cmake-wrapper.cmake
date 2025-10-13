# For very old ports whose upstream do not properly set the minimum CMake version.
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0057 NEW)
cmake_policy(SET CMP0094 NEW)

if(@PythonFinder_NO_OVERRIDE@)
    _find_package(${ARGS})
    return()
endif()

find_path(
        @PythonFinder_PREFIX@_INCLUDE_DIR
        NAMES "Python.h"
        PATHS "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
        PATH_SUFFIXES "python@PYTHON_VERSION_MAJOR@.@PYTHON_VERSION_MINOR@"
        NO_DEFAULT_PATH
)

find_library(
        @PythonFinder_PREFIX@_LIBRARY
        NAMES
        "python@PYTHON_VERSION_MAJOR@@PYTHON_VERSION_MINOR@"
        "python@PYTHON_VERSION_MAJOR@.@PYTHON_VERSION_MINOR@"
        PATHS "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib"
        NO_DEFAULT_PATH
)

find_program(
        @PythonFinder_PREFIX@_EXECUTABLE
        NAMES "python" "python@PYTHON_VERSION_MAJOR@.@PYTHON_VERSION_MINOR@"
        PATHS "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/@PORT@"
        NO_DEFAULT_PATH
)

# Invoke FindPython
_find_package(${ARGS})

if (DEFINED @PythonFinder_PREFIX@_STDLIB)
    # The standard library path may need normalizing
    cmake_path(NORMAL_PATH @PythonFinder_PREFIX@_STDLIB OUTPUT_VARIABLE @PythonFinder_PREFIX@_STDLIB)
endif ()

if(@VCPKG_LIBRARY_LINKAGE@ STREQUAL static)
    # Prebuilt binaries do not provide a static library
    message(FATAL_ERROR "Static linkage is not supported against @PORT@")
endif()