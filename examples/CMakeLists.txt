include(ExternalProject)

ExternalProject_Add(Local
    SOURCE_DIR ${PROJECT_SOURCE_DIR}
    CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:FILEPATH=${CMAKE_BINARY_DIR}
)

find_package(CICD PATHS ${CMAKE_BINARY_DIR})

if (NOT CICD_FOUND)
    message(WARNING "CICD local build not yet done, please build and re-run CMake")
    return()
endif()

cicd_add_package(test
    DISPLAY_NAME    "Test Package"
    PACKAGE_NAME    "Test-Package"
    PACKAGE_VERSION 2.1.0
    QT_VERSION      6.10.0
    QT_TOOLS
        tool_ifw
        tool_cmake
)

cicd_generate_workflow(test
    WINDOWS LINUX
    WORKFLOWS_DIR ${CMAKE_BINARY_DIR}
    QT_VERSION "6.9.0"
    QT_TOOLS "ifw_tools"
)
