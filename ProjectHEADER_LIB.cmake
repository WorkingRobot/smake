function(s_define_project_internal)
    if(S_CURRENT_PROJECT_SOURCES)
        message(FATAL_ERROR "The header only library ${S_CURRENT_PROJECT_NAME} cannot have explicitly defined sources")
    endif()

    add_library(${S_CURRENT_PROJECT_SANITIZED_NAME} INTERFACE)
    target_include_directories(${S_CURRENT_PROJECT_SANITIZED_NAME} INTERFACE .)
endfunction()

function(s_define_project_alias_internal)
    add_library(${S_CURRENT_PROJECT_NAME} ALIAS ${S_CURRENT_PROJECT_SANITIZED_NAME})
endfunction()

s_end_sources()
