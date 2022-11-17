include_guard(GLOBAL)

function(s_sanitize_project_name VARIABLE NAME)
    string(REPLACE "::" "-" NAME ${NAME})
    set(${VARIABLE} ${NAME} PARENT_SCOPE)
endfunction()

function(s_project_internal)
    s_sanitize_project_name(S_CURRENT_PROJECT_SANITIZED_NAME ${S_CURRENT_PROJECT_NAME})
    s_hoist_variable(S_CURRENT_PROJECT_SANITIZED_NAME)

    include(Project${S_CURRENT_PROJECT_TYPE})
endfunction()

macro(s_project NAME TYPE)
    set(S_CURRENT_PROJECT_NAME ${NAME})
    set(S_CURRENT_PROJECT_TYPE ${TYPE})

    cmake_parse_arguments(S_CURRENT_PROJECT "IS_SIMPLE;IS_DISABLED" "IMPORTED_LOCATION" "PLATFORMS" ${ARGN})

    if (S_CURRENT_PROJECT_IS_DISABLED)
        message("Not building ${S_CURRENT_PROJECT_NAME} because it's disabled")
        return()
    endif()

    if (S_CURRENT_PROJECT_PLATFORMS)
        if (NOT PROJECT_PLATFORM IN_LIST S_CURRENT_PROJECT_PLATFORMS)
            message("Not building ${S_CURRENT_PROJECT_NAME} because it's unsupported (only for ${S_CURRENT_PROJECT_PLATFORMS})")
            return()
        endif()
    endif()

    s_project_internal()
endmacro()

function(s_define_project_alias)
    if (S_CURRENT_PROJECT_NAME STREQUAL S_CURRENT_PROJECT_SANITIZED_NAME)
        return()
    endif()

    s_define_project_alias_internal()
endfunction()

function(s_define_project)
    s_define_project_internal()

    s_define_project_alias()
endfunction()

set_property(GLOBAL PROPERTY S_ALL_SOURCES)
function(s_push_sources)
    file(RELATIVE_PATH REL_PATH ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
    foreach(SOURCE ${S_CURRENT_PROJECT_SOURCES})
        list(APPEND PROJECT_SOURCES ${REL_PATH}/${SOURCE})
    endforeach()
    set_property(GLOBAL APPEND PROPERTY S_ALL_SOURCES ${PROJECT_SOURCES})
endfunction()

function(s_end_sources)
    s_define_project()
    s_push_sources()
endfunction()

function(s_link_libraries)
    target_link_libraries(${S_CURRENT_PROJECT_SANITIZED_NAME} ${ARGV})
endfunction()

function(s_compile_definitions)
    target_compile_definitions(${S_CURRENT_PROJECT_SANITIZED_NAME} ${ARGV})
endfunction()
