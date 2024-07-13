# Test config variables
set(language "" CACHE STRING "language to use")
set(include "stdlib.h" CACHE STRING "include to check")

# Test definition
cmake_minimum_required(VERSION 3.24)
set(project_name cmake_helpers_test)
project(${project_name} LANGUAGES CXX C)

find_file(cmake_helpers "helpers.cmake" PATHS "../../.." ".")
include(${cmake_helpers})

check_includes(INCLUDES ${include} VAR STDLIB_EXISTS LANGUAGE ${language})
if(DEFINED STDLIB_EXISTS)
    add_executable(${project_name} main.cpp)
endif()