cmake_minimum_required(VERSION 3.24)
set(project_name check_symbols_test)
project(${project_name} CXX)

find_file(CMAKE_HELPERS "helpers.cmake" PATHS "../../.." ".")
include(${CMAKE_HELPERS})

check_symbol(SYMBOL "exit" FILES "stdlib.h" VAR EXIT_EXISTS)
if(DEFINED EXIT_EXISTS)
    add_executable(${project_name} main.cpp)
endif()