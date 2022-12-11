function(s_define_project_internal)
    add_executable(${S_CURRENT_PROJECT_SANITIZED_NAME} ${S_CURRENT_PROJECT_SOURCES})

    s_set_default_properties()
    s_add_dll_copying()
endfunction()

function(s_define_project_alias_internal)
    add_executable(${S_CURRENT_PROJECT_NAME} ALIAS ${S_CURRENT_PROJECT_SANITIZED_NAME})
endfunction()

if (S_CURRENT_PROJECT_IS_SIMPLE)
    s_add_dir_recursive(.)
    s_end_sources()
endif()
