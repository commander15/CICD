list(APPEND CPACK_GENERATOR IFW)

include(CPackIFW)

set(CPACK_IFW_PACKAGE_TITLE "${SOFTWARE_NAME} Setup")
set(CPACK_IFW_PACKAGE_WIZARD_STYLE Aero)
set(CPACK_IFW_PACKAGE_TITLE_COLOR green)
set(CPACK_IFW_PACKAGE_START_MENU_DIRECTORY "${SOFTWARE_NAME}")
set(CPACK_IFW_PACKAGE_RUN_PROGRAM "@TargetDir@/bin/${SOFTWARE_TARGET}") # ToDo: try retriving name fist

# ToDo: remove hard coding
set(CPACK_IFW_ROOT ${Qt6_DIR}/../../../../../Tools/QtInstallerFramework/4.10)

cpack_ifw_configure_component(Program
    NAME qtworkflow
    VERSION ${PROJECT_VERSION}
    ESSENTIAL FORCED_INSTALLATION
    SORTING_PRIORITY 1
)

cpack_ifw_configure_component(QtDependencies
    NAME qt
    VERSION ${Qt6Core_VERSION}
    ESSENTIAL FORCED_INSTALLATION
)
