cmake_minimum_required(VERSION 3.30)

project(CICD
    DESCRIPTION "CI/CD pipeline building helper CMake library."
    VERSION 1.0.0
)

# Project options
option(CICD_BUILD_EXAMPLES OFF)

configure_file(
    .github/workflows/cross_platform_deploy.yml.in
    ${CMAKE_CURRENT_SOURCE_DIR}/.github/workflows/cross_platform_deploy.yml
    @ONLY
)

# Adding sources
add_subdirectory(src)

# Adding examples
if (CICD_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

# Packaging
set(CPACK_PACKAGE_NAME      CICD)
set(CPACK_PACKAGE_VERSION   ${PROJECT_VERSION})
set(CPACK_PACKAGE_FILE_NAME CICD-${PROJECT_VERSION})
set(CPACK_PACKAGE_DIRECTORY ${CMAKE_BINARY_DIR}/release)
set(CPACK_GENERATOR         ZIP TGZ)
include(CPack)
