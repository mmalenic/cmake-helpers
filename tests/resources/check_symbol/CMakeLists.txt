# Test config variables
set(mode
    ""
    CACHE STRING "mode to use"
)
set(symbol
    "exit"
    CACHE STRING "symbol to search for"
)
set(run_twice
    FALSE
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
project(${name} CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../src" ".")
include(toolbelt)

toolbelt_check_symbol(
    SYMBOL
    ${symbol}
    FILES
    "stdlib.h"
    VAR
    EXIT_EXISTS
    ${mode}
)

if(${run_twice})
    toolbelt_check_symbol(
        SYMBOL
        ${symbol}
        FILES
        "stdlib.h"
        VAR
        EXIT_EXISTS
        ${mode}
    )
endif()

if(DEFINED EXIT_EXISTS)
    add_executable(${name} main.cpp)
endif()
