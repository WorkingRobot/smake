function(s_define_project_internal)
    message(FATAL_ERROR "The import only library ${S_CURRENT_PROJECT_NAME} cannot have any sources")
endfunction()

function(s_define_project_alias_internal)

endfunction()

add_library(${S_CURRENT_PROJECT_NAME} UNKNOWN IMPORTED GLOBAL)
target_include_directories(${S_CURRENT_PROJECT_NAME} INTERFACE ${S_CURRENT_PROJECT_INCLUDED_LOCATION})
