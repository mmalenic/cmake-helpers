# Test config variables
set(components
    ""
    CACHE STRING "components to use"
)
set(version
    ""
    CACHE STRING "version to use"
)
set(visibility
    ""
    CACHE STRING "visibility to use"
)
set(find_package_args
    ""
    CACHE STRING "extra find package args"
)

# Test definition
cmake_minimum_required(VERSION 3.24)
set(name cmake_helpers_test)
project(${name} CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../src" ".")
include(helpers)

add_executable(${name} main.cpp)

enable_testing()
setup_gtest(${namer})
