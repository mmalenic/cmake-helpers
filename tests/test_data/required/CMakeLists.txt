# Test config variables
set(error FALSE CACHE BOOL "whether this is the error test case")

# Test definition
cmake_minimum_required(VERSION 3.24)
set(project_name cmake_helpers_test)
project(${project_name} CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../src")
include(helpers)

set(arg TRUE)
if(error)
    unset(arg)
endif()

helpers_required(arg)

add_executable(${project_name} main.cpp)
