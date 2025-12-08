function(ccp_externalize_apple_debuginfo)
    if(NOT VCPKG_TARGET_IS_OSX)
        return()
    endif()

    set(options "")
    set(single_value_keywords "")
    set(multi_value_keywords "BUILD_PATHS")
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
            "${options}" "${single_value_keywords}" "${multi_value_keywords}"
    )

    set(BUILD_PATHS
        "${CURRENT_PACKAGES_DIR}/bin/*.so" # package currently being built
        "${CURRENT_PACKAGES_DIR}/debug/bin/*.so"
        "${CURRENT_INSTALLED_DIR}/bin/*.so" # packages already installed that could be dependencies
        "${CURRENT_INSTALLED_DIR}/debug/bin/*.so"
        "${CURRENT_INSTALLED_DIR}/lib/*.dylib"
        "${CURRENT_INSTALLED_DIR}/debug/lib/*.dylib"
    )

    # include build paths supplied as arguments
    if(DEFINED arg_BUILD_PATHS)
        list(APPEND BUILD_PATHS ${arg_BUILD_PATHS})
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(GLOB_RECURSE out_libs ${BUILD_PATHS})

        foreach(lib IN LISTS out_libs)
            message(STATUS "externlalizing debug info for ${lib}")
            get_filename_component(target_name ${lib} NAME_WLE)
            get_filename_component(target_directory ${lib} DIRECTORY)
            set(SYM_FILE ${target_directory}/${target_name}.sym)

            if (NOT EXISTS ${SYM_FILE})
                execute_process(
                    COMMAND dsymutil ${lib} -f -o ${SYM_FILE}
                    RESULT_VARIABLE extract_error_code
                    OUTPUT_VARIABLE extract_line
                )

                if(NOT extract_error_code EQUAL "0")
                    message(WARNING "Unable to find debug information for: ${lib}. dsymutil had the following output: ${extract_line}")
                else()
                    execute_process(
                        COMMAND strip -Sxl ${lib}
                        RESULT_VARIABLE strip_error_code
                        OUTPUT_VARIABLE strip_line
                    )

                    if(NOT strip_error_code EQUAL "0")
                        message(WARNING "Unable to strip debug information from: ${lib}. strip had the following output: ${strip_Line}")
                    endif()
                endif()
            else()
                message(STATUS "Debug info for ${lib} already externalized")
            endif()

        endforeach()
    endif()

endfunction()
