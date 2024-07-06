# Test config variables
set(mode "" CACHE STRING "mode to use")
set(symbol "exit" CACHE STRING "symbol to search for")

# Test definition
cmake_minimum_required(VERSION 3.24)
set(project_name cmake_helpers_test)
project(${project_name} CXX)

find_file(cmake_helpers "helpers.cmake" PATHS "../../.." ".")
include(${cmake_helpers})

check_symbol(SYMBOL ${symbol} FILES "stdlib.h" VAR EXIT_EXISTS MODE ${mode})
if(DEFINED EXIT_EXISTS)
    add_executable(${project_name} main.cpp)
endif()