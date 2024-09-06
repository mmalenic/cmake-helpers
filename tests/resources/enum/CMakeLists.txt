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
set(name cmake_toolbelt_test)
project(${name} CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../src" ".")
include(toolbelt)

set(enum_a TRUE)
if(error)
    set(enum_c TRUE)
endif()

toolbelt_enum(enum_a enum_b enum_c)

add_executable(${name} main.cpp)
