# Simplified CMake: CMake for Minimalists

## TLDR

SMake is a CMake framework to allow for quick, one-time setup for your projects without any of the maintenance. It gets rid of all the boilerplate required for modern C++ projects and puts them in neat little commands.

## Example

```CMake
# Creates foo.exe using all the source files located in the current directory
s_project(foo EXEC IS_SIMPLE)

# Includes packages automagically using the current dependency manager
s_add_dependency(PRIVATE OpenSSL)
s_add_dependency(PRIVATE unofficial-breakpad)
s_add_dependency(PRIVATE libbacktrace)
```

Here's the equivalent CMake code:
```CMake
add_executable(foo "main.cpp" "a.cpp" "b.cpp" "c/d.cpp" "c/e/f.cpp" ...)

find_package(OpenSSL REQUIRED)
target_link_libraries(foo PRIVATE OpenSSL::SSL OpenSSL::Crypto)

find_package(unofficial-breakpad REQUIRED)
target_link_libraries(foo PRIVATE unofficial::breakpad::libbreakpad unofficial::breakpad::libbreakpad_client)

find_path(LIBBACKTRACE_INCLUDE_DIR "backtrace.h" REQUIRED)
find_library(LIBBACKTRACE_LIBRARY "backtrace" REQUIRED)
target_include_directories(foo PRIVATE ${LIBBACKTRACE_INCLUDE_DIR})
target_link_libraries(foo PRIVATE ${LIBBACKTRACE_LIBRARY})
```

## Advanced Example

`/deps/libA/CMakeLists.txt`
```CMake
s_project(foo::A STATIC_LIB IS_SIMPLE)

s_add_dependency(PRIVATE OpenSSL)
```

`/deps/libB/CMakeLists.txt`
```CMake
L4_project(foo::B HEADER_LIB IS_SIMPLE)
```

`/deps/libC/CMakeLists.txt`
```CMake
s_project(foo::C STATIC_LIB IS_SIMPLE)

s_link_libraries(PRIVATE foo::A)
s_link_libraries(PUBLIC foo::B)
```

`/src/CMakeLists.txt`
```CMake
s_project(foo EXEC IS_SIMPLE)

s_link_libraries(PRIVATE foo::C)
```

`/CMakeLists.txt`
```CMake
s_add_subdirectories_in(deps)
add_subdirectory(src)
```

# Documentation

(TODO)

# Features

SMake currently supports the following build targets:

- EXEC: An executable created with `add_executable`
- EXEC_WIN32: `add_executable` with the `WIN32` subsystem
- HEADER_LIB: `add_library` with `INTERFACE` visibility. Dependents automatically include the right directory
- SHARED_LIB: `add_library` of `SHARED` type
- STATIC_LIB: `add_library` of `STATIC` type
- MODULE_LIB: `add_library` of `MODULE` type
- IMPORT_LIB: `add_library` of `IMPORTED` type for already built libraries

# Planned

- DRIVER_LNX Linux driver with KBuild