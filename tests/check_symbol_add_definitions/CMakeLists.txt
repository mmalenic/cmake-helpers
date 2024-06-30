cmake_minimum_required(VERSION 3.24)
set(project_name check_symbol_test)
project(${project_name} CXX)

include("${CMAKE_SOURCE_DIR}/../../helpers.cmake")

check_symbol(SYMBOL "exit" FILES "stdlib.h" VAR EXIT_EXISTS MODE check_symbol_exists)
if(DEFINED EXIT_EXISTS)
    add_executable(${project_name} main.cpp)
endif()