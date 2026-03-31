include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

set(PACKAGE_TEMPLATES_DIR ${CMAKE_INSTALL_DATAROOTDIR}/CICD/templates)
set(PACKAGE_INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/CICD)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/CICDConfig.cmake.in
    ${CMAKE_CURRENT_SOURCE_DIR}/CICDConfig.cmake
    INSTALL_DESTINATION ${PACKAGE_INSTALL_DESTINATION}
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/CICDConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
    ARCH_INDEPENDENT
)

set(PACKAGE_SOURCES
    CICDConfig.cmake
    CICDConfigVersion.cmake
)

set(PACKAGE_FILES
    CICDMacros.cmake
)

file(
    GLOB_RECURSE TEMPLATE_FILES
    LIST_DIRECTORIES FALSE
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    "templates/*"
)

add_custom_target(CICD ALL
    SOURCES
        CICDConfig.cmake.in
        ${PACKAGE_FILES}
        ${TEMPLATE_FILES}
)

install(FILES ${PACKAGE_SOURCES} ${PACKAGE_FILES} DESTINATION ${PACKAGE_INSTALL_DESTINATION})
install(DIRECTORY templates/ DESTINATION ${PACKAGE_TEMPLATES_DIR})
