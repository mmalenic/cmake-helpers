# Test config variables
set(language
    ""
    CACHE STRING "language to use"
)
set(include
    "stdlib.h"
    CACHE STRING "include to check"
)
set(run_twice
    TRUE
    CACHE BOOL "run the include check twice"
)
set(run_clang_tidy
    FALSE
    CACHE BOOL "run clang tidy when building"
)

if(run_clang_tidy)
    set(CMAKE_CXX_CLANG_TIDY clang-tidy)
endif()

# Test definition
cmake_minimum_required(VERSION 3.24)
set(name cmake_toolbelt_test)
project(${name} LANGUAGES CXX C)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../src" ".")
include(toolbelt)

toolbelt_check_includes(INCLUDES ${include} VAR STDLIB_EXISTS LANGUAGE ${language})

if(${run_twice})
    toolbelt_check_includes(INCLUDES ${include} VAR STDLIB_EXISTS LANGUAGE ${language})
endif()

if(DEFINED STDLIB_EXISTS)
    add_executable(${name} main.cpp)
endif()
