include_guard(GLOBAL)

function(s_get_git_default_branch)
    execute_process(COMMAND git -C ${CMAKE_SOURCE_DIR} remote 
                    OUTPUT_VARIABLE GIT_REMOTE_NAME
                    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (GIT_REMOTE_NAME)
        execute_process(COMMAND git -C ${CMAKE_SOURCE_DIR} remote show ${GIT_REMOTE_NAME}
                        OUTPUT_VARIABLE GIT_REMOTE_DATA
                        ERROR_QUIET)
        string(REGEX MATCH "HEAD branch: ([^\n]+)" GIT_REMOTE_BRANCH ${GIT_REMOTE_DATA})

        set(GIT_DEFAULT_BRANCH ${CMAKE_MATCH_1})
    endif()

    if (NOT GIT_DEFAULT_BRANCH)
        set(GIT_DEFAULT_BRANCH "main")        
        message(WARNING "Could not find the default branch. Using \"main\".")
    endif()
    s_hoist_variable(GIT_DEFAULT_BRANCH)
endfunction()

function(s_get_git_info)
    execute_process(COMMAND git -C ${CMAKE_SOURCE_DIR} log --pretty=format:'%h' -n 1
                OUTPUT_VARIABLE GIT_REVISION
                ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT GIT_REVISION)
        set(GIT_BRANCH "orphaned")
        set(GIT_REVISION "ffffff")
        set(GIT_IS_MODIFIED FALSE)
    else()
        string(STRIP "${GIT_REVISION}" GIT_REVISION)
        string(SUBSTRING "${GIT_REVISION}" 1 6 GIT_REVISION)

        execute_process(
            COMMAND git -C ${CMAKE_SOURCE_DIR} diff --quiet --exit-code
            RESULT_VARIABLE GIT_IS_MODIFIED)
        if (GIT_IS_MODIFIED EQUAL 0)
            set(GIT_IS_MODIFIED FALSE)
        else()
            set(GIT_IS_MODIFIED TRUE)
        endif()

        execute_process(
            COMMAND git -C ${CMAKE_SOURCE_DIR} rev-parse --abbrev-ref HEAD
            OUTPUT_VARIABLE GIT_BRANCH)
        string(STRIP "${GIT_BRANCH}" GIT_BRANCH)
    endif()

    s_hoist_variable(GIT_BRANCH)
    s_hoist_variable(GIT_REVISION)
    s_hoist_variable(GIT_IS_MODIFIED)
endfunction()

function(s_get_vcpkg_manifest_try_get VARIABLE MANIFEST_PROPERTY)
    if (NOT ${VARIABLE})
        string(JSON ${VARIABLE} ERROR_VARIABLE MANIFEST_JSON_ERROR GET ${MANIFEST_JSON} ${MANIFEST_PROPERTY})
    endif()
    s_hoist_variable(${VARIABLE})
endfunction()

function(s_get_vcpkg_manifest_info)
    file(READ ${VCPKG_MANIFEST_DIR}/vcpkg.json MANIFEST_JSON)

    s_get_vcpkg_manifest_try_get(MANIFEST_JSON_NAME "name")
    if (NOT MANIFEST_JSON_NAME)
        message(FATAL_ERROR "The vcpkg manifest does not have any attached name")
    endif()
    s_hoist_variable(MANIFEST_JSON_NAME)

    s_get_vcpkg_manifest_try_get(MANIFEST_JSON_VERSION "version")
    s_get_vcpkg_manifest_try_get(MANIFEST_JSON_VERSION "version-semver")
    s_get_vcpkg_manifest_try_get(MANIFEST_JSON_VERSION "version-date")
    s_get_vcpkg_manifest_try_get(MANIFEST_JSON_VERSION "version-string")
    if (NOT MANIFEST_JSON_VERSION)
        message(FATAL_ERROR "The vcpkg manifest does not have any attached version information")
    endif()
    s_hoist_variable(MANIFEST_JSON_VERSION)

    s_get_vcpkg_manifest_try_get(MANIFEST_JSON_DESCRIPTION "description")
    if (NOT MANIFEST_JSON_DESCRIPTION)
        message(FATAL_ERROR "The vcpkg manifest does not have any attached description")
    endif()
    s_hoist_variable(MANIFEST_JSON_DESCRIPTION)
endfunction()

function(s_get_version_info)
    cmake_parse_arguments(S_VERSION_INFO "NO_VCPKG;NO_GIT" "DEFAULT_BRANCH" "" ${ARGN})

    if (NOT S_VERSION_INFO_NO_VCPKG)
        s_get_vcpkg_manifest_info()

        set(PROJECT_NAME ${MANIFEST_JSON_NAME})
        set(PROJECT_VERSION ${MANIFEST_JSON_VERSION})
        set(PROJECT_DESCRIPTION ${MANIFEST_JSON_DESCRIPTION})

        s_hoist_variable(PROJECT_NAME)
        s_hoist_variable(PROJECT_VERSION)
        s_hoist_variable(PROJECT_DESCRIPTION)
    endif()

    if (NOT S_VERSION_INFO_NO_GIT)
        if (S_VERSION_INFO_DEFAULT_BRANCH)
            set(GIT_DEFAULT_BRANCH ${S_VERSION_INFO_DEFAULT_BRANCH})
        else()
            message(AUTHOR_WARNING "Retrieving default branch from remote. This will take a few seconds and will fail if offline.")
            s_get_git_default_branch()
            message(AUTHOR_WARNING "Try manually setting it with ${CMAKE_CURRENT_FUNCTION}(DEFAULT_BRANCH \"${GIT_DEFAULT_BRANCH}\") instead.")
        endif()

        s_get_git_info()

        set(PROJECT_VERSION_BRANCH ${GIT_BRANCH})
        set(PROJECT_VERSION_REVISION ${GIT_REVISION})
        set(PROJECT_VERSION_IS_MODIFIED ${GIT_IS_MODIFIED})

        set(PROJECT_VERSION_LONG ${PROJECT_VERSION})
        if (NOT PROJECT_VERSION_BRANCH STREQUAL GIT_DEFAULT_BRANCH)
            set(PROJECT_VERSION_LONG ${PROJECT_VERSION_LONG}-${PROJECT_VERSION_BRANCH})
        endif()
        set(PROJECT_VERSION_LONG ${PROJECT_VERSION_LONG}+${PROJECT_VERSION_REVISION})
        if (PROJECT_VERSION_IS_MODIFIED)
            set(PROJECT_VERSION_LONG ${PROJECT_VERSION_LONG}.dev)
        endif()

        s_hoist_variable(PROJECT_VERSION_BRANCH)
        s_hoist_variable(PROJECT_VERSION_REVISION)
        s_hoist_variable(PROJECT_VERSION_IS_MODIFIED)
        s_hoist_variable(PROJECT_VERSION_LONG)
    endif()
endfunction()

function(s_add_version_defs PATH)
    set_property(
        SOURCE ${PATH}
        APPEND
        PROPERTY COMPILE_DEFINITIONS
        CONFIG_PROJECT_NAME="${PROJECT_NAME}"
        CONFIG_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
        CONFIG_VERSION_MINOR=${PROJECT_VERSION_MINOR}
        CONFIG_VERSION_PATCH=${PROJECT_VERSION_PATCH}
        CONFIG_VERSION_TWEAK=${PROJECT_VERSION_TWEAK}
        CONFIG_VERSION_BRANCH="${PROJECT_VERSION_BRANCH}"
        CONFIG_VERSION_REVISION="${PROJECT_VERSION_REVISION}"
        $<$<BOOL:${PROJECT_VERSION_IS_MODIFIED}>:CONFIG_VERSION_IS_MODIFIED>
        CONFIG_VERSION="${PROJECT_VERSION}"
        CONFIG_VERSION_LONG="${PROJECT_VERSION_LONG}"
    )
endfunction()
