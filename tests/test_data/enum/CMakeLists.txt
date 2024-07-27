# Test config variables
set(error FALSE CACHE BOOL "whether this is the error test case")

# Test definition
cmake_minimum_required(VERSION 3.24)
set(project_name cmake_helpers_test)
project(${project_name} CXX)

find_file(cmake_helpers "helpers.cmake" PATHS "../../.." ".")
include(${cmake_helpers})

set(enum_a TRUE)
if(error)
    set(enum_c TRUE)
endif()

helpers_enum(enum_a enum_b enum_c)

add_executable(${project_name} main.cpp)