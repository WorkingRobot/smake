function(_define_project_internal)
    add_library(${CURRENT_PROJECT_SANITIZED_NAME} MODULE ${CURRENT_PROJECT_SOURCES})

    _set_default_properties()
endfunction()

function(_define_project_alias_internal)
    add_library(${CURRENT_PROJECT_NAME} ALIAS ${CURRENT_PROJECT_SANITIZED_NAME})
endfunction()

if (CURRENT_PROJECT_IS_SIMPLE)
    _add_dir_recursive(.)
    end_sources()
endif()