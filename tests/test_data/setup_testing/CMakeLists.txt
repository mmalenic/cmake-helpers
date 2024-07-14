# Test config variables
set(components "" CACHE STRING "components to use")
set(version "" CACHE STRING "version to use")
set(visibility "" CACHE STRING "visibility to use")
set(find_package_args "" CACHE STRING "extra find package args")


# Test definition
cmake_minimum_required(VERSION 3.24)
set(project_name cmake_helpers_test)
project(${project_name} CXX)

find_file(cmake_helpers "helpers.cmake" PATHS "../../.." ".")
include(${cmake_helpers})

add_executable(${project_name} main.cpp)

setup_testing(${project_name} "")