set(CPACK_GENERATOR)

include(CPackComponent)

cpack_add_component(${SOFTWARE_COMPONENT}
    DISPLAY_NAME "${SOFTWARE_NAME}"
    DESCRIPTION "Program core files."
    REQUIRED
)

cpack_add_component(QtDependencies
    DISPLAY_NAME "Qt"
    DESCRIPTION "Qt libraries."
    VERSION ${Qt6Core_VERSION}
    REQUIRED
)
