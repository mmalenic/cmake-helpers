# Test definition
cmake_minimum_required(VERSION 3.24)
set(CMAKE_CXX_STANDARD 14)
set(project_name cmake_helpers_test)
project(${project_name} CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../src")
include(helpers)

add_executable(${project_name} main.cpp)

helpers_embed("auto_literal.h" "auto_literal" EMBED "embed_one.txt" TARGET ${project_name})
helpers_embed("const_literal.h" "const_literal" EMBED "embed_one.txt" TARGET ${project_name} CHAR_LITERAL)
helpers_embed("byte_array.h" "byte_array" EMBED "embed_one.txt" TARGET ${project_name} BYTE_ARRAY)
helpers_embed("define.h" "DEFINE" EMBED "embed_one.txt" TARGET ${project_name} DEFINE)

helpers_embed("auto_literal_namespace.h" "auto_literal_namespace" NAMESPACE "application::detail" EMBED "embed_one.txt" TARGET ${project_name})
helpers_embed("const_literal_namespace.h" "const_literal_namespace" NAMESPACE "application::detail" EMBED "embed_one.txt" TARGET ${project_name} CHAR_LITERAL)
helpers_embed("byte_array_namespace.h" "byte_array_namespace" NAMESPACE "application::detail" EMBED "embed_one.txt" TARGET ${project_name} BYTE_ARRAY)

helpers_embed("auto_literal_multi.h" "auto_literal_multi" NAMESPACE "application::detail" EMBED "embed_one.txt" "embed_two.txt" TARGET ${project_name})
helpers_embed("const_literal_multi.h" "const_literal_multi" NAMESPACE "application::detail" EMBED "embed_one.txt" "embed_two.txt" TARGET ${project_name} CHAR_LITERAL)
helpers_embed("byte_array_multi.h" "byte_array_multi" NAMESPACE "application::detail" EMBED "embed_one.txt" "embed_two.txt" TARGET ${project_name} BYTE_ARRAY)
helpers_embed("define_multi.h" "DEFINE_MULTI" EMBED "embed_one.txt" "embed_two.txt" TARGET ${project_name} DEFINE)

target_include_directories(${project_name} PRIVATE ${cmake_helpers_ret})