set(CICD_PACKAGE_DIRECTORY ${CMAKE_BINARY_DIR}/CICD/release)

function(cicd_add_workflow target)
    set(options ON_WORKFLOW_DISPATCH)
    set(oneValueArgs NAME FILENAME)
    set(multiValueArgs ON_PUSH_ON ON_TAGS SOURCES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV})

    add_custom_target(${target} ALL SOURCES ${ARG_SOURCES})

    set(PROPERTIES)

    if (NOT ARG_NAME)
        set(ARG_NAME ${target})
    endif()

    if (NOT ARG_FILENAME)
        set(ARG_FILENAME ${ARG_NAME}.yml)
    endif()

    set_target_properties(${target}
        PROPERTIES
            WORKFLOW_NAME "${ARG_NAME}"
            OUTPUT_NAME "${ARG_FILENAME}"
    )

    set(TRIGGERS)

    if (ARG_ON_WORKFLOW_DISPATCH)
        list(APPEND TRIGGERS ON_WORKFLOW_DISPATCH)
    endif()

    if (ARG_ON_PUSH_ON)
        list(APPEND TRIGGERS ON_PUSH_BRANCHES ${ARG_ON_PUSH_ON})
    endif()

    if (ARG_ON_TAGS)
        list(APPEND TRIGGERS ON_PUSH_TAGS ${ARG_ON_TAGS})
    endif()

    if (NOT TRIGGERS)
        set(TRIGGERS ON_WORKFLOW_DISPATCH ON_PUSH_BRANCHES "\"main\"")
    endif()

    cicd_workflow_add_event_triggers(${target} ${TRIGGERS})

    cmake_language(EVAL CODE "
        message(${workflow})
        message(${ARG_FILENAME})
        cmake_language(DEFER CALL cicd_generate_workflow_file ${workflow} ${ARG_FILENAME})
    ")
endfunction()

function(cicd_workflow_add_event_triggers workflow)
    set(options ON_WORKFLOW_DISPATCH ON_WORKFLOW_CALL)
    set(oneValueArgs)
    set(multiValueArgs ON_PUSH_BRANCHES ON_PUSH_PATHS ON_PUSH_TAGS ON_PULL_REQUEST ON_SCHEDULE ON_RELEASE)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV})
endfunction()

function(cicd_workflow_add_job workflow job_id)
    set(options)
    set(oneValueArgs NAME MATRIX RUNS_ON)
    set(multiValueArgs NEEDS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV})
endfunction()

function(cicd_workflow_add_job_step workflow job_id step_id)
    set(options CONTINUES_ON_ERROR)
    set(oneValueArgs IF NAME USES)
    set(multiValueArgs RUN WITH)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV})
endfunction()

function(cicd_generate_workflow_file workflow filename)
    get_target_property(NAME ${workflow} WORKFLOW_NAME)
    file(WRITE ${filename}  "Name: ${NAME}\n\n")
    file(APPEND ${filename} "on:\n")

    target_sources(${workflow} PRIVATE ${filename})
endfunction()

# Matrix

macro(cicd_add_matrix matrix)
    set(${matrix}_VARIABLES)
    set(${matrix}_INCLUDES)
endmacro()

macro(cicd_matrix_add matrix var)
    list(APPEND ${matrix}_VARIABLES ${var})
    set(${matrix}_var_${var} ${ARGN})
endmacro()

macro(cicd_matrix_include matrix)
    list(LENGTH ${matrix}_INCLUDES index)
    list(APPEND ${matrix}_INCLUDES ${index})
    set(${matrix}_inc_${index} ${ARGN})
endmacro()

macro(cicd_matrix_build matrix out-var)
    set(INDENT "  ")
    set(CONTENT)

    macro(parse)
        if (ARGC GREATER 1)
            set(value ${ARGV})
            list(TRANSFORM value PREPEND "\"")
            list(TRANSFORM value APPEND  "\"")
            list(JOIN value ", " items)
            set(value "[ ${items} ]")
        elseif (ARGC EQUAL 1)
            set(value ${ARGV})
        else()
            unset(value)
        endif()
    endmacro()

    macro(get_var var)
        parse(${${matrix}_var_${var}})
    endmacro()

    macro(get_inc inc)
        set(value ${${matrix}_inc_${inc}})
    endmacro()

    foreach (var ${${matrix}_VARIABLES})
        get_var(${var} var)
        string(APPEND CONTENT "${INDENT}${var}: ${value}\n")
    endforeach()

    string(APPEND CONTENT "\n${INDENT}include:\n")
    string(APPEND INDENT "  ")
    foreach (inc ${${matrix}_INCLUDES})
        get_inc(${inc})
        foreach (item ${value})
            string(APPEND CONTENT "${INDENT}${item}\n")
        endforeach()
    endforeach()

    set(${out-var} ${CONTENT})
endmacro()

# Legacy

function(cicd_workflow_generate workflow)
    set(options)
    set(oneValueArgs FILENAME)
    set(multiValueArgs)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV})

    get_target_property(WORKFLOW_NAME ${workflow} WORKFLOW_NAME)

    if (NOT ARG_FILENAME)
        set(ARG_FILENAME ${WORKFLOW_NAME}.yml)
    endif()

    file(WRITE  ${ARG_WORKFLOW_NAME} "Name: ${ARG_WORKFLOW_NAME}\n\n")
    file(APPEND ${ARG_WORKFLOW_NAME} "on:\n")
endfunction()

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

function(cicd_generate_workflow_2 package)
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

function(cicd_generate_workflow_file2 filename)
    set(options ON_WORKFLOW_DISPATCH WINDOWS LINUX)
    set(oneValueArgs NAME RELEASE_NOTE_FILE QT_VERSION IFW_VERSION)
    set(multiValueArgs ON_PUSH_ON QT_TOOLS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV})

    # Not absolute file name, consider on source dir
    if (NOT EXISTS ${filename})
        set(filename ${CMAKE_CURRENT_SOURCE_DIR}/${filename})
    endif()

    # If no name provided, fallback to CI/CD Pipeline
    if (ARG_NAME)
        set(WORKFLOW_NAME ${ARG_NAME})
    else()
        set(WORKFLOW_NAME "CI/CD Pipeline")
    endif()

    # Processing RELEASE note file
    if (NOT EXISTS ${ARG_RELEASE_NOTE_FILE})
        if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${ARG_RELEASE_NOTE_FILE})
            set(ARG_RELEASE_NOTE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${ARG_RELEASE_NOTE_FILE})
        else()
            unset(ARG_RELEASE_NOTE_FILE)
            message(WARNING "Release note file doesn't exists")
        endif()
    endif()

    if (ARG_RELEASE_NOTE_FILE)
        file(RELATIVE_PATH RELEASE_NOTE_FILE ${CMAKE_SOURCE_DIR} ${ARG_RELEASE_NOTE_FILE})
    endif()

    set(PACKAGE_NAME     ${CPACK_PACKAGE_NAME})
    set(PACKAGE_VERSION  ${CPACK_PACKAGE_VERSION})

    # Triggers
    unset(TRIGGERS)

    if (NOT ARG_ON_PUSH_ON AND NOT ARG_ON_WORKFLOW_DISPATCH)
        set(ARG_ON_PUSH_ON main)
        set(ARG_ON_WORKFLOW_DISPATCH ON)
    endif()

    # On push
    if (ARG_ON_PUSH_ON)
        set(BRANCHES ${ARG_ON_PUSH_ON})
        list(TRANSFORM BRANCHES PREPEND "\"")
        list(TRANSFORM BRANCHES APPEND "\"")
        string(JOIN ", " BRANCHES ${BRANCHES})
        list(APPEND TRIGGERS "  push:\n    branches: [ ${BRANCHES} ]")
    endif()

    # On workflow_dispatch
    if (ARG_ON_WORKFLOW_DISPATCH)
        list(APPEND TRIGGERS "  workflow_dispatch: # Allow manual trigger")
    endif()

    string(JOIN "\n" TRIGGERS ${TRIGGERS})

    # Checking IFW informations
    if (ARG_IFW_VERSION)
        set(IFW_VERSION ${ARG_IFW_VERSION})
        list(APPEND ARG_QT_TOOLS "tools_ifw")
    endif()

    # Checking Qt informations
    if (ARG_QT_VERSION)
        set(QT_VERSION ${ARG_QT_VERSION})
    elseif (Qt6Core_FOUND)
        set(QT_VERSION ${Qt6Core_VERSION})
    elseif (Qt5Core_FOUND)
        set(QT_VERSION ${Qt5Core_VERSION})
    else()
        set(QT_VERSION 6.9.0)
    endif()
    list(REMOVE_DUPLICATES ARG_QT_TOOLS)
    string(JOIN " " QT_TOOLS ${ARG_QT_TOOLS})

    configure_file(${CICD_TEMPLATES_DIR}/cicd_pipeline.yml.in ${filename} @ONLY)
endfunction()
