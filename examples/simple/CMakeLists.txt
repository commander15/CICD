cmake_minimum_required(VERSION 3.30)

project(SimpleCICD VERSION 1.0)

# Find Qt
find_package(Qt6 REQUIRED COMPONENTS Core)

# Find CICD
find_package(CICD REQUIRED)

# Program
qt_add_executable(Program main.cpp)
qt_generate_deploy_app_script(TARGET Program OUTPUT_SCRIPT DEPLOY_SCRIPT)

# Installation
include(GNUInstallDirs)
install(TARGETS Program RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(SCRIPT ${DEPLOY_SCRIPT})

# Packaging
set(CPACK_PACKAGE_NAME      Simple)
set(CPACK_PACKAGE_VERSION   ${PROJECT_VERSION})
set(CPACK_PACKAGE_FILE_NAME Simple-${PROJECT_VERSION})
set(CPACK_GENERATOR         ZIP TGZ)
include(CPack)

# Workflow generation
cicd_add_workflow(workflow
    ON_PUSH_BRANCHES "main"
    ON_WORKFLOW_DISPATCH
)

cicd_workflow_add_event_triggers(workflow
    ON_PUSH_BRANCHES "alpha" "beta" "releases/**"
    ON_PUSH_PATHS    "**.js" "**.ts"
    ON_PUSH_TAGS     "v.*.*" "beta.*"
    ON_RELEASE       "published" "prereleased" "released"
    ON_SCHEDULE      "30 5 * * 1,3" "0 5,17 * * 2,4"
    ON_WORKFLOW_DISPATCH
)

cicd_add_matrix(os_matrix)
cicd_matrix_add(os_matrix os windows-latest ubuntu-latest)
cicd_matrix_add(os_matrix qt "6.9.0" "6.9.1" "6.10.0")
cicd_matrix_include(os_matrix gtest 3.20 doxygen 1.1)
cicd_matrix_include(os_matrix gtest 3.25 doxygen 1.2)
cicd_matrix_build(os_matrix MATRIX)
message(${MATRIX})

cicd_workflow_add_job(workflow build
    NAME    "Build"
    RUNS_ON "${{matrix.os}}"
    MATRIX ${WINDOWS_BUILD} ${LINUX_BUILD}
)

cicd_workflow_add_job_step(workflow build checkout
    NAME "Checkout Code"
    USES "actions/checkout@v4"
)

cicd_generate_workflow_file(
    .github/workflows/cicd_pipeline.yml
    RELEASE_NOTE_FILE notes/RELEASE-1.0.txt
    IFW_VERSION 4.10
)
