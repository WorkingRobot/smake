include_guard(GLOBAL)

function(s_set_cxx_standard STANDARD)
    s_set_properties(PROPERTIES CXX_STANDARD ${STANDARD})
endfunction()

function(s_force_pdbs)
    if(MSVC)
        s_compile_options(PRIVATE /Zi)
        s_set_properties(PROPERTIES
            LINK_FLAGS "/DEBUG /OPT:REF /OPT:ICF"
            COMPILE_PDB_NAME ${S_CURRENT_PROJECT_SANITIZED_NAME}
            COMPILE_PDB_OUTPUT_DIR ${CMAKE_BINARY_DIR}
        )
    endif()
endfunction()

function(s_add_platform_macro)
    s_compile_definitions(PRIVATE CONFIG_VERSION_PLATFORM=${PROJECT_PLATFORM} CONFIG_VERSION_PLATFORM_${PROJECT_PLATFORM})
endfunction()

function(s_disable_stdlib)
    s_compile_options(PRIVATE -nostdlib -fno-exceptions)
endfunction()

function(s_use_pic)
    s_set_properties(PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
endfunction()

function(s_report_undefined_refs)
    s_set_properties(PROPERTIES LINK_OPTIONS "--no-undefined")
endfunction()

function(s_enable_clang_tidy TIDY_ARGS)
    s_set_properties(PROPERTIES
        CXX_CLANG_TIDY ${TIDY_ARGS}
        C_CLANG_TIDY ${TIDY_ARGS}
    )
endfunction()

function(s_set_arch ARCH)
    if (MSVC)
        if(ARCH STREQUAL "AVX2")
            set(OPT "/arch:AVX2")
        elseif(ARCH STREQUAL "AVX512")
            set(OPT "/arch:AVX512")
        else()
            message(FATAL_ERROR "Unsupported architecture: ${ARCH}")
        endif()
    else()
        if(ARCH STREQUAL "AVX2")
            set(OPT "-march=x86-64-v3")
        elseif(ARCH STREQUAL "AVX512")
            set(OPT "-march=x86-64-v4")
        else()
            message(FATAL_ERROR "Unsupported architecture: ${ARCH}")
        endif()
    endif()
    s_compile_options(PRIVATE ${OPT})
endfunction()


function(s_set_default_properties)
    s_set_cxx_standard(23)
    s_force_pdbs()
    s_add_platform_macro()
endfunction()
