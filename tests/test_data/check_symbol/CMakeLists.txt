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

# Test definition
cmake_minimum_required(VERSION 3.24)
set(project_name cmake_helpers_test)
project(${project_name} CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../src" ".")
include(helpers)

helpers_check_symbol(
    SYMBOL
    ${symbol}
    FILES
    "stdlib.h"
    VAR
    EXIT_EXISTS
    ${mode}
)

if(${run_twice})
    helpers_check_symbol(
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
    add_executable(${project_name} main.cpp)
endif()
