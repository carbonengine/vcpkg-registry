#[[=
This portfile wraps the original boost-context portfile in order to provide universal binaries on macOS.
It achieves this by building boost-context for the individual arm64 and x86_64 architectures, and then
combining the produced libraries in a universal binary using the `lipo` command.

There is a slight deviation from the usual pattern of simply including the original portfile when building
universal binaries. This is because boost-context requires architecture specific options, but those are set
to be empty in the original portfile.
=]]
set(FEATURE_OPTIONS_arm64 "-DBOOST_CONTEXT_ABI=aapcs")
set(FEATURE_OPTIONS_x86_64 "-DBOOST_CONTEXT_ABI=sysv")

if(TARGET_TRIPLET MATCHES ".*universal-osx.*")
    find_program(LIPO_COMMAND lipo REQUIRED)
    if(NOT CARBON_x86_64_TRIPLET)
        message(FATAL_ERROR "The triplet file is missing the `CARBON_x86_64_TRIPLET` variable. Please set it to a triplet to use for the x86_64 build")
    endif()
    if(NOT CARBON_arm64_TRIPLET)
        message(FATAL_ERROR "The triplet file is missing the `CARBON_arm64_TRIPLET` variable. Please set it to a triplet to use for the arm64 build")
    endif()
    string(REPLACE ${TARGET_TRIPLET} ${CARBON_x86_64_TRIPLET} x64_PACKAGES_DIR ${CURRENT_PACKAGES_DIR})
    string(REPLACE ${TARGET_TRIPLET} ${CARBON_arm64_TRIPLET} arm64_PACKAGES_DIR ${CURRENT_PACKAGES_DIR})
    set(_ORIG_OSX_ARCH ${VCPKG_OSX_ARCHITECTURES})
    set(_ORIG_TARGET_TRIPLET ${TARGET_TRIPLET})
    set(_ORIG_TARGET_ARCH ${VCPKG_TARGET_ARCHITECTURE})
    set(_ORIG_PACKAGES_DIR ${CURRENT_PACKAGES_DIR})
    set(_ORIG_CMAKE_VARS_FILE ${VCPKG_CMAKE_VARS_FILE})
    foreach(_OSX_ARCH ${_ORIG_TARGET_ARCH})
        set(TARGET_TRIPLET ${CARBON_${_OSX_ARCH}_TRIPLET})
        set(VCPKG_TARGET_ARCHITECTURE ${_OSX_ARCH})
        set(VCPKG_OSX_ARCHITECTURES ${_OSX_ARCH})
        set(FEATURE_OPTIONS "-DCMAKE_PREFIX_PATH=${_VCPKG_INSTALLED_DIR}/${_ORIG_TARGET_TRIPLET}")
        list(APPEND FEATURE_OPTIONS "-DBOOST_CONTEXT_ARCHITECTURE=${_OSX_ARCH}")
        list(APPEND FEATURE_OPTIONS ${FEATURE_OPTIONS_${_OSX_ARCH}})
        string(REPLACE ${_ORIG_TARGET_TRIPLET} ${TARGET_TRIPLET} CURRENT_PACKAGES_DIR ${_ORIG_PACKAGES_DIR})

        vcpkg_from_github(
                OUT_SOURCE_PATH SOURCE_PATH
                REPO boostorg/context
                REF boost-${VERSION}
                SHA512 4ac38c31e576f02901fd889403466fb10d40513384468a971f7774a04479fced85c40809b8a5eef89daabd8f5eaed712061f2e25e84ac5a66acbb112a7954c89
                HEAD_REF master
                PATCHES
                marmasm.patch
        )

        boost_configure_and_install(
            SOURCE_PATH "${SOURCE_PATH}"
            OPTIONS ${FEATURE_OPTIONS}
        )
    endforeach()
    set(VCPKG_CMAKE_VARS_FILE ${_ORIG_CMAKE_VARS_FILE})
    set(CURRENT_PACKAGES_DIR ${_ORIG_PACKAGES_DIR})
    set(VCPKG_OSX_ARCHITECTURES ${_ORIG_OSX_ARCH})
    set(VCPKG_TARGET_ARCHITECTURE ${_ORIG_TARGET_ARCHS})
    set(TARGET_TRIPLET ${_ORIG_TARGET_TRIPLET})
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory "${x64_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/include")
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory "${x64_PACKAGES_DIR}/share" "${CURRENT_PACKAGES_DIR}/share")
    if (VCPKG_LIBRARY_LINKAGE MATCHES "static")
        file(GLOB_RECURSE x64_LIBS "${x64_PACKAGES_DIR}/lib/*.a")
        file(GLOB_RECURSE arm64_LIBS "${arm64_PACKAGES_DIR}/lib/*.a")
    else()
        file(GLOB_RECURSE x64_LIBS "${x64_PACKAGES_DIR}/lib/*.dylib")
        file(GLOB_RECURSE arm64_LIBS "${arm64_PACKAGES_DIR}/lib/*.dylib")
    endif()
    # this assumes that the libs generated for each architecture have identical names, and that both architectures generate the same amount of libs
    foreach(x64 arm64 IN ZIP_LISTS x64_LIBS arm64_LIBS)
        cmake_path(GET x64 FILENAME _FILENAME)
        cmake_path(GET x64 PARENT_PATH _BASEPATH)
        cmake_path(RELATIVE_PATH _BASEPATH BASE_DIRECTORY "${x64_PACKAGES_DIR}/lib/" OUTPUT_VARIABLE _RELATIVE_PART)
        if (IS_SYMLINK ${x64})
            file(READ_SYMLINK ${x64} _LINK_TARGET)
            cmake_path(GET _LINK_TARGET FILENAME _LINK_NAME)
            execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink "${CURRENT_PACKAGES_DIR}/lib/${_LINK_NAME}" "${CURRENT_PACKAGES_DIR}/lib/${_FILENAME}" COMMAND_ERROR_IS_FATAL ANY COMMAND_ECHO STDOUT)
        else()
            execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory "${CURRENT_PACKAGES_DIR}/lib/${_RELATIVE_PART}" COMMAND_ERROR_IS_FATAL ANY COMMAND_ECHO STDOUT)
            execute_process(COMMAND ${LIPO_COMMAND} ${x64} ${arm64} -create -output "${CURRENT_PACKAGES_DIR}/lib/${_RELATIVE_PART}/${_FILENAME}" COMMAND_ERROR_IS_FATAL ANY COMMAND_ECHO STDOUT)
        endif()
    endforeach()
else()
    include(${CMAKE_CURRENT_LIST_DIR}/portfile.original.cmake)
endif()
