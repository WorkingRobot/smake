cmake_policy(SET CMP0007 NEW)

get_filename_component(BINARY_DIR ${BINARY_FILE} DIRECTORY)

find_program(DUMPBIN "dumpbin")
if(DUMPBIN)
    execute_process(
        COMMAND dumpbin /DEPENDENTS "${BINARY_FILE}"
        OUTPUT_VARIABLE COMMAND_OUTPUT
    )
    string(REPLACE "\n" ";" DEPENDENCIES ${COMMAND_OUTPUT})
    list(FILTER DEPENDENCIES INCLUDE REGEX "^    [^ ].*\\.dll")
    list(TRANSFORM DEPENDENCIES STRIP)
else()
    find_program(OBJDUMP "llvm-objdump")
    if(OBJDUMP)
        execute_process(
            COMMAND llvm-objdump -p "${BINARY_FILE}"
            OUTPUT_VARIABLE COMMAND_OUTPUT
        )
        string(REPLACE "\n" ";" DEPENDENCIES ${COMMAND_OUTPUT})
        list(FILTER DEPENDENCIES INCLUDE REGEX "^    DLL Name: .*\\.dll")
        list(TRANSFORM DEPENDENCIES REPLACE "^    DLL Name: " "")
    else()
        message(FATAL_ERROR "Neither dumpbin nor llvm-objdump could be found. Can not take care of dll dependencies.")
    endif()
endif()

foreach(DEPENDENCY ${DEPENDENCIES})
    foreach(SHARED_LIB ${SHARED_LIBS})
        get_filename_component(FILENAME ${SHARED_LIB} NAME)
        if (FILENAME STREQUAL DEPENDENCY)
            file(COPY_FILE ${SHARED_LIB} ${BINARY_DIR}/${DEPENDENCY} ONLY_IF_DIFFERENT)
            list(REMOVE_ITEM SHARED_LIBS ${SHARED_LIB})
            break()
        endif()
    endforeach()
endforeach()
