# Test config variables
set(error
    FALSE
    CACHE BOOL "whether this is the error test case"
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
set(name cmake_helpers_test)
project(${name} CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../src" ".")
include(helpers)

set(arg TRUE)
if(error)
    unset(arg)
endif()

helpers_required(arg)

add_executable(${name} main.cpp)
