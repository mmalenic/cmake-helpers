cmake_minimum_required(VERSION 3.24)
project(
    cmake_toolbelt
    VERSION 0.1.1
    DESCRIPTION "a small collection of CMake build functions."
    HOMEPAGE_URL "https://github.com/mmalenic/cmake-toolbelt"
)

# Include src directory.
list(FIND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/src" src_path)
if(${src_path} STREQUAL "-1")
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/src")
endif()

include(toolbelt)
