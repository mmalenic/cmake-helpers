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
set(run_clang_tidy
    FALSE
    CACHE BOOL "run clang tidy when building"
)

if(run_clang_tidy)
    set(CMAKE_CXX_CLANG_TIDY clang-tidy)
endif()

# Test definition
cmake_minimum_required(VERSION 3.24)
set(name cmake_toolbelt_test)
project(${name} CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../src" ".")
include(toolbelt)

add_executable(${name} main.cpp)

enable_testing()
toolbelt_setup_gtest(${name})
