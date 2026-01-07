cmake_minimum_required(VERSION 3.28.1)
project(python_greenlet LANGUAGES C CXX)

find_package(Python3 COMPONENTS Development REQUIRED)

SET(EXTRA_LINK_LIBRARIES "")
SET(EXTRA_COMPILE_OPTIONS "")

include(cmake/CcpGlobalSettings.cmake)
include(cmake/CcpTargetConfigurations.cmake)

if(WIN32)
    enable_language(ASM_MASM)

    SET(ASM_OPTIONS "-x assembler-with-cpp")
    SET(EXTRA_LINK_LIBRARIES switch_x64_masm)
    SET(EXTRA_COMPILE_OPTIONS "/EHsr /GT")

    add_library(switch_x64_masm OBJECT src/greenlet/platform/switch_x64_masm.asm)
elseif(APPLE)
    SET(EXTRA_COMPILE_OPTIONS "--std=gnu++11")
endif()

ccp_add_library(_greenlet SHARED src/greenlet/greenlet.cpp)

set_target_properties(_greenlet
        PROPERTIES
        DEBUG_POSTFIX ""
        INTERNAL_POSTFIX ""
        TRINITYDEV_POSTFIX ""
        OUTPUT_NAME _greenlet
)

target_compile_options(_greenlet PRIVATE ${EXTRA_COMPILE_OPTIONS})

target_link_libraries(_greenlet
    PRIVATE
        Python3::Python
        "${EXTRA_LINK_LIBRARIES}"
)

target_include_directories(_greenlet INTERFACE
        $<INSTALL_INTERFACE:include>
)

install(FILES src/greenlet/greenlet.h DESTINATION include/)
install(FILES src/greenlet/__init__.py DESTINATION bin/python/greenlet/)

if(WIN32)
    install(FILES $<TARGET_FILE_DIR:_greenlet>/_greenlet.pyd DESTINATION bin/)
elseif(APPLE)
    install(FILES $<TARGET_FILE_NAME:_greenlet>  DESTINATION bin/)
endif()
install(FILES greenletConfig.cmake DESTINATION ${CMAKE_INSTALL_PREFIX}/share/greenlet/)
