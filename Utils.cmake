include_guard(GLOBAL)

macro(s_hoist_variable VARIABLE)
    set(${VARIABLE} ${${VARIABLE}} PARENT_SCOPE)
endmacro()

function(s_dump_variables)
    get_cmake_property(_vars VARIABLES)
    list(SORT _vars)
    foreach(_var ${_vars})
        message(STATUS "${_var}=${${_var}}")
    endforeach()
endfunction()

function(s_add_subdirectories_in PATH)
    file(GLOB CHILD_LIST ${PATH}/*)
    foreach(CHILD_PATH ${CHILD_LIST})
        if(IS_DIRECTORY ${CHILD_PATH})
            list(APPEND SUBDIR_LIST ${CHILD_PATH})
        endif()
    endforeach()
    list(REMOVE_DUPLICATES SUBDIR_LIST)

    foreach(SUBDIR_PATH ${SUBDIR_LIST})
        add_subdirectory(${SUBDIR_PATH})
    endforeach()
endfunction()

set_property(GLOBAL PROPERTY S_IMPORT_SHARED_LIBS)
function(s_add_dll_copying)
    if(PROJECT_PLATFORM STREQUAL "win")
        get_property(SHARED_LIBS GLOBAL PROPERTY S_IMPORT_SHARED_LIBS)
        foreach(SHARED_LIB ${SHARED_LIBS})
            get_property(SHARED_IMPLIB TARGET ${SHARED_LIB} PROPERTY IMPORTED_LOCATION)
            if (SHARED_IMPLIB)
                list(APPEND SHARED_IMPLIBS ${SHARED_IMPLIB})
            endif()
        endforeach()
        add_custom_command(TARGET "${S_CURRENT_PROJECT_SANITIZED_NAME}" POST_BUILD
                COMMAND "${CMAKE_COMMAND}"
                    "-DBINARY_FILE=$<TARGET_FILE:${S_CURRENT_PROJECT_SANITIZED_NAME}>"
                    "-DSHARED_LIBS=${SHARED_IMPLIBS}"
                    -P "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CopySharedDlls.cmake"
                VERBATIM)
    endif()
endfunction()

function(s_get_platform_identifier VARIABLE)
    # Taken from https://github.com/microsoft/vcpkg/blob/9259a0719d94c402aae2ab7975bc096afdec15df/scripts/buildsystems/vcpkg.cmake#L332
    if (NOT CMAKE_SYSTEM_NAME)
        set(SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME})
    else()
        set(SYSTEM_NAME ${CMAKE_SYSTEM_NAME})
    endif()
    if (SYSTEM_NAME STREQUAL "Windows")
        set(${VARIABLE} "win")
    elseif (SYSTEM_NAME STREQUAL "Linux")
        set(${VARIABLE} "lnx")
    elseif (SYSTEM_NAME STREQUAL "Darwin")
        set(${VARIABLE} "osx")
    else()
        message(FATAL_ERROR "Unsupported platform: ${SYSTEM_NAME}")
    endif()
    s_hoist_variable(${VARIABLE})
endfunction()

s_get_platform_identifier(PROJECT_PLATFORM)
