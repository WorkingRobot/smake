include_guard(GLOBAL)

function(s_get_git_info)
    execute_process(COMMAND git -C ${CMAKE_SOURCE_DIR} log --pretty=format:'%h' -n 1
                OUTPUT_VARIABLE GIT_REVISION
                ERROR_QUIET)

    if (GIT_REVISION STREQUAL "")
        # No git info
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

function(s_get_vcpkg_manifest_version_info MANIFEST_PROPERTY)
    if ((NOT DEFINED MANIFEST_JSON_VERSION) OR (MANIFEST_JSON_VERSION MATCHES "NOTFOUND$"))
        string(JSON MANIFEST_JSON_VERSION ERROR_VARIABLE MANIFEST_JSON_ERROR GET ${MANIFEST_JSON} ${MANIFEST_PROPERTY})
    endif()
    s_hoist_variable(MANIFEST_JSON_VERSION)
endfunction()

function(s_get_vcpkg_manifest_info)
    file(READ ${CMAKE_SOURCE_DIR}/vcpkg.json MANIFEST_JSON)

    string(JSON MANIFEST_JSON_NAME GET ${MANIFEST_JSON} "name")

    s_get_vcpkg_manifest_version_info("version")
    s_get_vcpkg_manifest_version_info("version-semver")
    s_get_vcpkg_manifest_version_info("version-date")
    s_get_vcpkg_manifest_version_info("version-string")
    if (MANIFEST_JSON_VERSION MATCHES "NOTFOUND$")
        message(FATAL_ERROR "The vcpkg manifest does not have any attached version information")
    endif()

    message(STATUS "${MANIFEST_JSON_NAME} - ${MANIFEST_JSON_VERSION}")
endfunction()

function(s_retrieve_version_info)
    s_get_git_info()

    set(PROJECT_VERSION_BRANCH ${GIT_BRANCH})
    set(PROJECT_VERSION_REVISION ${GIT_REVISION})
    set(PROJECT_VERSION_IS_MODIFIED ${GIT_IS_MODIFIED})

    set(PROJECT_VERSION_LONG ${PROJECT_VERSION})
    if (NOT PROJECT_VERSION_BRANCH STREQUAL "main")
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
        CONFIG_VERSION_BRANCH="${PROJECT_VERSION_BRANCH}"
        CONFIG_VERSION_REVISION="${PROJECT_VERSION_REVISION}"
        $<$<BOOL:${PROJECT_VERSION_IS_MODIFIED}>:CONFIG_VERSION_IS_MODIFIED>
        CONFIG_VERSION="${PROJECT_VERSION}"
        CONFIG_VERSION_LONG="${PROJECT_VERSION_LONG}"
    )
endfunction()
