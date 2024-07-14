# Test config variables
#set(components "" CACHE STRING "components to use")

# Test definition
cmake_minimum_required(VERSION 3.24)
set(CMAKE_CXX_STANDARD 14)
set(project_name cmake_helpers_test)
project(${project_name} CXX)

find_file(cmake_helpers "helpers.cmake" PATHS "../../.." ".")
include(${cmake_helpers})

add_executable(${project_name} main.cpp)

create_header_file("include_constexpr_auto.h" "include" TARGET_FILE_NAMES "embed_one.txt" TARGET ${project_name} VISIBILITY PRIVATE)
create_header_file("include_const_char.h" "include" TARGET_FILE_NAMES "embed_one.txt" TARGET ${project_name} VISIBILITY PRIVATE MODE "const_char")
create_header_file("include_define_constant.h" "include" TARGET_FILE_NAMES "embed_one.txt" TARGET ${project_name} VISIBILITY PRIVATE MODE "define_constant")
create_header_file("include_constexpr_auto_namespace.h" "include" NAMESPACE "application::detail" TARGET_FILE_NAMES "embed_one.txt" TARGET ${project_name} VISIBILITY PRIVATE)
create_header_file("include_const_char_namespace.h" "include" NAMESPACE "application::detail" TARGET_FILE_NAMES "embed_one.txt" TARGET ${project_name} VISIBILITY PRIVATE MODE "const_char")
create_header_file("include_constexpr_auto_multi.h" "include" NAMESPACE "application::detail" TARGET_FILE_NAMES "embed_one.txt" "embed_two.txt" TARGET ${project_name} VISIBILITY PRIVATE)
create_header_file("include_const_char_multi.h" "include" NAMESPACE "application::detail" TARGET_FILE_NAMES "embed_one.txt" "embed_two.txt" TARGET ${project_name} VISIBILITY PRIVATE MODE "const_char")
create_header_file("include_define_constant_multi.h" "include" TARGET_FILE_NAMES "embed_one.txt" "embed_two.txt" TARGET ${project_name} VISIBILITY PRIVATE MODE "define_constant")
#create_header_file("include.h" "include" "application::detail" TARGET_FILE_NAMES "embed.txt" TARGET ${project_name} SOURCE_VISIBILITY PRIVATE DIR_VISIBILITY PRIVATE)
#create_header_file("include.h" "include" "application::detail" TARGET_FILE_NAMES "embed.txt" TARGET ${project_name} SOURCE_VISIBILITY PRIVATE DIR_VISIBILITY PRIVATE)
#create_header_file("include.h" "include" "application::detail" TARGET_FILE_NAMES "embed.txt" TARGET ${project_name} SOURCE_VISIBILITY PRIVATE DIR_VISIBILITY PRIVATE)
#create_header_file("include.h" "include" "application::detail" TARGET_FILE_NAMES "embed.txt" TARGET ${project_name} SOURCE_VISIBILITY PRIVATE DIR_VISIBILITY PRIVATE)
#create_header_file("include.h" "include" "application::detail" TARGET_FILE_NAMES "embed.txt" TARGET ${project_name} SOURCE_VISIBILITY PRIVATE DIR_VISIBILITY PRIVATE)

target_include_directories(${project_name} PRIVATE ${cmake_helpers_ret})