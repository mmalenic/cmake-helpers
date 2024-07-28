# Test config variables
set(language "" CACHE STRING "language to use")
set(include "stdlib.h" CACHE STRING "include to check")
set(run_twice TRUE CACHE BOOL "run the include check twice")

# Test definition
cmake_minimum_required(VERSION 3.24)
set(project_name cmake_helpers_test)
project(${project_name} LANGUAGES CXX C)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../src")
include(helpers)

helpers_check_includes(INCLUDES ${include} VAR STDLIB_EXISTS LANGUAGE ${language})

if(${run_twice})
    helpers_check_includes(INCLUDES ${include} VAR STDLIB_EXISTS LANGUAGE ${language})
endif()

if(DEFINED STDLIB_EXISTS)
    add_executable(${project_name} main.cpp)
endif()