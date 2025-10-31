include(CMakePackageConfigHelpers)

configure_package_config_file(
    CICDConfig.cmake.in
    ${CMAKE_CURRENT_SOURCE_DIR}/CICDConfig.cmake
    INSTALL_DESTINATION lib/cmake/CICD
)

write_basic_package_version_file(
    CICDConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
    ARCH_INDEPENDENT
)

set(PACKAGE_FILES
    CICDConfig.cmake
    CICDMacros.cmake
)

file(
    GLOB_RECURSE TEMPLATE_FILES
    LIST_DIRECTORIES FALSE
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    "templates/*"
)

add_custom_target(CICD ALL SOURCES ${PACKAGE_FILES} ${TEMPLATE_FILES})

install(FILES ${PACKAGE_FILES} DESTINATION lib/cmake/CICD)
install(DIRECTORY templates/ DESTINATION share/CICD/templates)
