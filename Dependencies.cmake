include_guard(GLOBAL)

function(s_add_dependency_pkgconfig NAME)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(PKGCONFIG_LIB REQUIRED ${NAME})
    target_link_libraries(${S_CURRENT_PROJECT_SANITIZED_NAME} ${VISIBILITY} ${PKGCONFIG_LIB_LIBRARIES})
    target_include_directories(${S_CURRENT_PROJECT_SANITIZED_NAME} ${VISIBILITY} ${PKGCONFIG_LIB_INCLUDE_DIRS})
endfunction()

function(s_add_dependency_manual INCLUDE_PATH LIBRARY_NAME)
    find_path(MANUAL_INCLUDE_DIR ${INCLUDE_PATH} REQUIRED)
    find_library(MANUAL_LIBRARY ${LIBRARY_NAME} REQUIRED)
    target_include_directories(${S_CURRENT_PROJECT_SANITIZED_NAME} ${VISIBILITY} ${MANUAL_INCLUDE_DIR})
    target_link_libraries(${S_CURRENT_PROJECT_SANITIZED_NAME} ${VISIBILITY} ${MANUAL_LIBRARY})
endfunction()

function(s_add_dependency_findpkg PKG_NAME)
    cmake_parse_arguments(PARSE_ARGV 1 FINDPKG "CONFIG" "" "LIBS")
    if (${FINDPKG_CONFIG})
        find_package(${PKG_NAME} CONFIG REQUIRED)
    else()
        find_package(${PKG_NAME} REQUIRED)
    endif()
    target_link_libraries(${S_CURRENT_PROJECT_SANITIZED_NAME} ${VISIBILITY} ${FINDPKG_LIBS})
endfunction()

function(s_add_dependency NAME VISIBILITY)
    cmake_language(CALL s_dependency_${NAME})
endfunction()

function(s_dependency_JSON)
    s_add_dependency_findpkg(RapidJSON CONFIG LIBS rapidjson)
endfunction()

function(s_dependency_HTTP)
    s_add_dependency_findpkg(cpr CONFIG LIBS cpr::cpr)
endfunction()

function(s_dependency_libbacktrace)
    s_add_dependency_manual(backtrace.h backtrace)
endfunction()

function(s_dependency_breakpad)
    s_add_dependency_findpkg(unofficial-breakpad CONFIG LIBS unofficial::breakpad::libbreakpad unofficial::breakpad::libbreakpad_client)
endfunction()

function(s_dependency_libfmt)
    s_add_dependency_findpkg(fmt CONFIG LIBS fmt::fmt)
endfunction()

function(s_dependency_date)
    s_add_dependency_findpkg(date CONFIG LIBS date::date date::date-tz)
endfunction()

function(s_dependency_OpenSSL)
    s_add_dependency_findpkg(OpenSSL LIBS OpenSSL::Crypto)
endfunction()
