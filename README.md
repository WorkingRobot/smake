# Simplified CMake: CMake for Minimalists

## TLDR

SMake is a CMake framework to allow for quick, one-time setup for your projects without any of the maintenance. It gets rid of all the boilerplate required for modern C++ projects and puts them in neat little commands.

## Example

Here's an example using SMake:
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

# Breakpad requires CONFIG, while OpenSSL does not
find_package(unofficial-breakpad CONFIG REQUIRED)
target_link_libraries(foo PRIVATE unofficial::breakpad::libbreakpad unofficial::breakpad::libbreakpad_client)

# vcpkg's libbacktrace doesn't support find_package and therefore has to be done manually
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

## (TODO)

# Features

SMake currently supports the following build targets:

- EXEC: An executable created with `add_executable`
- EXEC_WIN32: `add_executable` with the `WIN32` subsystem
- HEADER_LIB: `add_library` with `INTERFACE` visibility. Dependents automatically include the right directory
- SHARED_LIB: `add_library` of `SHARED` type
- STATIC_LIB: `add_library` of `STATIC` type
- MODULE_LIB: `add_library` of `MODULE` type
- IMPORT_LIB: `add_library` of `IMPORTED` type for already built libraries

SMake currently supports:
- C++ style namespacing with `::` separators for project names
  - `s_project(foo::A::B ...)`
- One-line dependency management with [vcpkg](https://github.com/microsoft/vcpkg)
  - `s_add_dependency(VISIBILITY LIBRARY_NAME)`
- Automatic git version integration
  - `s_retrieve_version_info()`
  - Add macro support with `s_add_version_defs(file.cpp)`
- Cleaner property management with more expressive commands
  - `s_set_cxx_standard(20)`
  - `s_enable_clang_tidy()`
- Utility functions to reduce maintenance time
  - `s_add_subdirectories_in(DIR_NAME)`
  - `s_add_dir(DIR_NAME RECURSIVE)`
- Quick debugging support
  - `s_project` with `IS_DISABLED`
  - `s_dump_variables()`
- Quickly specificy platform-specific projects
  - `s_project(... PLATFORMS lnx mac)`

# Planned

- Automatically grab vcpkg `find_package` dependency code if available
- Support other project target properties
- Support other package managers
- Untested: C++20 module support
- If possible, get rid of the `s_end_sources()` call when not using `IS_SIMPLE`
- DRIVER_LNX build type: KBuild Linux driver with signing and DKMS support
- Other project types (suggestions and PRs are open!)

# Installation

```CMake
cmake_minimum_required(VERSION 3.20)
include(FetchContent)
FetchContent_Declare(
  smake
  GIT_REPOSITORY https://git.camora.dev/asriel/smake.git
  GIT_TAG        v1
)
FetchContent_MakeAvailable(smake)
include(${smake_SOURCE_DIR}/smake.cmake)
```