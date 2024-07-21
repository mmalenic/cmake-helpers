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
helpers_add_dep(${project_name} ZLIB LINK_COMPONENTS ${components} VERSION ${version} VISIBILITY ${visibility} FIND_PACKAGE_ARGS ${find_package_args})

# Repeating should not be an issue
helpers_add_dep(${project_name} ZLIB LINK_COMPONENTS ${components} VERSION ${version} VISIBILITY ${visibility} FIND_PACKAGE_ARGS ${find_package_args})