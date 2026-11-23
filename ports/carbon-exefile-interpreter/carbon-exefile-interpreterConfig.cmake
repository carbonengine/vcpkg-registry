function(ccp_prepare_interpreter)

    set(options "")
    set(single_value_keywords "TARGET;BUILD_TYPE;COMMAND_OUT;PYTHONPATH_OUT;RUN_DIR;BLUE_DIR_OUT")
    set(multi_value_keywords "")
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
            "${options}" "${single_value_keywords}" "${multi_value_keywords}"
    )

    find_dependency(Python3 COMPONENTS Interpreter REQUIRED)
    find_dependency(carbon-blue REQUIRED CONFIG)

    set(${arg_BLUE_DIR_OUT} $<TARGET_FILE_DIR:Blue> PARENT_SCOPE)

    if (DEFINED arg_BUILD_TYPE AND NOT arg_BUILD_TYPE MATCHES "Release")
	    # exefile's per-config postfixes are lower case (e.g. exefile_debug), which matters on case-sensitive file systems
	    string(TOLOWER "${arg_BUILD_TYPE}" BUILD_TYPE_LOWER)
	    set(EXEFILE_TOOL_NAME exefile_${BUILD_TYPE_LOWER})
	else()
	    set(EXEFILE_TOOL_NAME exefile)
	endif()
	find_program(EXEFILE_TOOL ${EXEFILE_TOOL_NAME} NO_CACHE)

	if(WIN32)
	    cmake_path(GET EXEFILE_TOOL PARENT_PATH EXEFILE_TOOL_DIR)
	    add_custom_command(
	            TARGET ${arg_TARGET} POST_BUILD
	            COMMAND ${CMAKE_COMMAND} -E copy_directory ${EXEFILE_TOOL_DIR} ${arg_RUN_DIR}
	            COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:Blue> ${arg_RUN_DIR}
	            COMMAND_EXPAND_LISTS
	    )
	    set(${arg_COMMAND_OUT} $<TARGET_FILE_DIR:${arg_TARGET}>/${EXEFILE_TOOL_NAME} PARENT_SCOPE)
	    set(${arg_PYTHONPATH_OUT} "$<TARGET_FILE_DIR:Blue>\;$<TARGET_FILE_DIR:${arg_TARGET}>\;${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin\;${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib\;${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/python\;${Python3_STDLIB}" PARENT_SCOPE)
	elseif(APPLE OR LINUX)
		set(${arg_COMMAND_OUT} ${EXEFILE_TOOL} PARENT_SCOPE)
		set(${arg_PYTHONPATH_OUT} "$<TARGET_FILE_DIR:Blue>:$<TARGET_FILE_DIR:${arg_TARGET}>:${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin:${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib:${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/python3.12/lib-dynload:${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/python:${Python3_STDLIB}" PARENT_SCOPE)
	endif()

endfunction()
