function(s_define_project_internal)
    message(FATAL_ERROR "The import only library ${S_CURRENT_PROJECT_NAME} cannot have any sources")
endfunction()

function(s_define_project_alias_internal)

endfunction()

add_library(${S_CURRENT_PROJECT_NAME} STATIC IMPORTED GLOBAL)
set_target_properties(${S_CURRENT_PROJECT_NAME} PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/${S_CURRENT_PROJECT_IMPORTED_LOCATION}")
if (S_CURRENT_PROJECT_IMPLIB_LOCATION)
    set_target_properties(${S_CURRENT_PROJECT_NAME} PROPERTIES IMPORTED_IMPLIB "${CMAKE_CURRENT_SOURCE_DIR}/${S_CURRENT_PROJECT_IMPLIB_LOCATION}")
endif()
target_include_directories(${S_CURRENT_PROJECT_NAME} INTERFACE ${S_CURRENT_PROJECT_INCLUDED_LOCATION})
