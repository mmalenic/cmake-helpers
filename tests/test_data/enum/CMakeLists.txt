# Test config variables
set(error
    FALSE
    CACHE BOOL "whether this is the error test case"
)

# Test definition
cmake_minimum_required(VERSION 3.24)
set(name cmake_helpers_test)
project(${name} CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../src" ".")
include(helpers)

set(enum_a TRUE)
if(error)
    set(enum_c TRUE)
endif()

helpers_enum(enum_a enum_b enum_c)

add_executable(${name} main.cpp)
