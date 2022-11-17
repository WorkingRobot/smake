include_guard(GLOBAL)

function(s_set_cxx_standard)
    set_target_properties(${S_CURRENT_PROJECT_SANITIZED_NAME} PROPERTIES CXX_STANDARD 23)
endfunction()

function(s_force_pdbs)
    if(MSVC AND CMAKE_BUILD_TYPE STREQUAL "Release")
        target_compile_options(${S_CURRENT_PROJECT_SANITIZED_NAME} PRIVATE /Zi)
        set_target_properties(${S_CURRENT_PROJECT_SANITIZED_NAME} PROPERTIES
            LINK_FLAGS "/DEBUG /OPT:REF /OPT:ICF"
            COMPILE_PDB_NAME ${S_CURRENT_PROJECT_SANITIZED_NAME}
            COMPILE_PDB_OUTPUT_DIR ${CMAKE_BINARY_DIR}
        )
    endif()
endfunction()

function(s_add_platform_macro)
    target_compile_definitions(${S_CURRENT_PROJECT_SANITIZED_NAME} PRIVATE CONFIG_VERSION_PLATFORM=${PROJECT_PLATFORM} CONFIG_VERSION_PLATFORM_${PROJECT_PLATFORM})
endfunction()

function(s_disable_stdlib)
    target_compile_options(${S_CURRENT_PROJECT_SANITIZED_NAME} PRIVATE -nostdlib -fno-exceptions)
endfunction()

function(s_use_pic)
    set_target_properties(${S_CURRENT_PROJECT_SANITIZED_NAME} PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
endfunction()

function(s_report_undefined_refs)
    set_target_properties(${S_CURRENT_PROJECT_SANITIZED_NAME} PROPERTIES LINK_OPTIONS "--no-undefined")
endfunction()

function(s_enable_clang_tidy)
    set_target_properties(${S_CURRENT_PROJECT_SANITIZED_NAME} PROPERTIES CXX_CLANG_TIDY "clang-tidy")
    set_target_properties(${S_CURRENT_PROJECT_SANITIZED_NAME} PROPERTIES C_CLANG_TIDY "clang-tidy")
endfunction()


function(s_set_default_properties)
    s_set_cxx_standard()
    s_force_pdbs()
    s_add_platform_macro()
    s_enable_clang_tidy()
endfunction()
