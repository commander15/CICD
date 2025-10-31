set(CICD_PACKAGE_DIRECTORY ${CMAKE_BINARY_DIR}/CICD/release)

function(cicd_add_package name)
    set(options)
    set(oneValueArgs PACKAGE_NAME PACKAGE_VERSION DISPLAY_NAME QT_VERSION)
    set(multiValueArgs QT_TOOLS SOURCES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV})

    add_custom_target(${name} SOURCES ${ARG_SOURCES})

    # Setting package name fallback to target name
    if (NOT ARG_PACKAGE_NAME)
        set(ARG_PACKAGE_NAME ${name})
    endif()

    # Setting package version fallback to lower level project version
    if (NOT ARG_PACKAGE_VERSION)
        set(ARG_PACKAGE_VERSION ${PROJECT_VERSION})
    endif()

    # Setting display name fallback to package name
    if (NOT ARG_DISPLAY_NAME)
        set(ARG_DISPLAY_NAME ${ARG_PACKAGE_NAME})
    endif()

    # Setting Qt version, fallback to version 6.9.0
    if (NOT ARG_QT_VERSION)
        set(ARG_QT_VERSION "6.9.0")
    endif()

    set_target_properties(${name}
        PROPERTIES
            PACKAGE_NAME    "${ARG_PACKAGE_NAME}"
            PACKAGE_VERSION "${ARG_PACKAGE_VERSION}"
            DISPLAY_NAME    "${ARG_DISPLAY_NAME}"
            QT_VERSION      "${ARG_QT_VERSION}"
            QT_TOOLS        "${ARG_QT_TOOLS}"
    )
endfunction()

function(cicd_generate_workflow package)
    set(options WINDOWS LINUX)
    set(oneValueArgs FILE_NAME WORKFLOWS_DIR )
    set(multiValueArgs)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV})

    # Getting package information
    get_target_property(DISPLAY_NAME    ${package} DISPLAY_NAME)
    get_target_property(PACKAGE_NAME    ${package} PACKAGE_NAME)
    get_target_property(PACKAGE_VERSION ${package} PACKAGE_VERSION)

    # Getting Qt related informations
    get_target_property(QT_VERSION ${package} QT_VERSION)
    get_target_property(QT_TOOLS   ${package} QT_TOOLS)
    string(JOIN " " QT_TOOLS ${QT_TOOLS})

    # Checking the workflows dir
    if (NOT ARG_WORKFLOWS_DIR)
        set(ARG_WORKFLOWS_DIR ${PROJECT_SOURCE_DIR}/.github/workflows)
    endif()

    # Checking if file name is provided, fallback to cicd_pipeline.yml
    if (NOT ARG_FILE_NAME)
        set(ARG_FILE_NAME cicd_pipeline.yml)
    endif()

    configure_file(${CICD_TEMPLATES_DIR}/cicd_pipeline.yml.in ${ARG_WORKFLOWS_DIR}/${ARG_FILE_NAME} @ONLY)
endfunction()
