include(CheckIncludeFiles)
include(CheckCXXSymbolExists)
include(CheckSymbolExists)
include(GoogleTest)

#[[.rst:
.. command:: helpers_check_symbol

A wrapper function around |check_cxx_symbol_exists|, or |check_symbol_exists| which adds compile time
definitions using |add_compile_definitions|.

.. code-block:: cmake

    helpers_check_symbol(
        SYMBOL <symbol>
        VAR <var>
        FILES [<file>...]
        [C]
    )

By default, this checks if the given ``SYMBOL`` can be found after including ``FILES`` using
|check_cxx_symbol_exists|. A cached result is written to ``VAR`` and a compile-time definition with the
same name as ``VAR`` is created if this check succeeds. Setting the ``C`` flag uses |check_symbol_exists|
instead.

This function calls the check function and compile definitions function directly, so all features of
those commands are supported, such as setting the ``CMAKE_REQUIRED_*`` variables.

Examples
^^^^^^^^

Check if the "exit" symbol can be found after including "stdlib.h" in a source file using the C++ compiler.
The result of this check is stored in EXIT_EXISTS and a compile time definition with the value ``EXIT_EXISTS=1`
is created if the check was successful.

.. code-block:: cmake

    helpers_check_symbol(
        SYMBOL "exit"
        FILES "stdlib.h"
        VAR EXIT_EXISTS
    )

This causes the following program to exit with 0 if the symbol exists:

.. code-block:: c++

    int main() {
    #if defined(EXIT_EXISTS)
        return 0;
    #else
        return 1;
    #endif
    }

.. |check_cxx_symbol_exists| replace:: :command:`check_cxx_symbol_exists <command:check_cxx_symbol_exists>`
.. |check_symbol_exists| replace:: :command:`check_symbol_exists <command:check_symbol_exists>`
.. |add_compile_definitions| replace:: :command:`add_compile_definitions <command:add_compile_definitions>`
]]
function(helpers_check_symbol)
    set(options C)
    set(one_value_args SYMBOL VAR MODE)
    set(multi_value_args FILES)
    cmake_parse_arguments("" "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

    check_required_arg(_VAR)
    check_required_arg(_SYMBOL)
    check_required_arg(_FILES)

    _helpers_check_cached(${_VAR} "helpers_check_symbol")

    if(_C)
        _helpers_status("helpers_check_symbol" "using check_symbol_exists")
        check_symbol_exists("${_SYMBOL}" "${_FILES}" "${_VAR}")
    else()
        _helpers_status("helpers_check_symbol" "using check_cxx_symbol_exists")
        check_cxx_symbol_exists("${_SYMBOL}" "${_FILES}" "${_VAR}")
    endif()

    if(${_VAR})
        add_compile_definitions("${_VAR}=1")
    endif()
endfunction()

#[[.rst:
.. command:: helpers_check_includes

A wrapper function around |check_include_files| which adds compile time definitions using
|add_compile_definitions|.

.. code-block:: cmake

    helpers_check_includes(
        VAR <var>
        INCLUDES <file>...
        [LANGUAGE C | CXX]
    )

By default, this checks that the given ``INCLUDES`` can be included in a source file and compiled. A cached
result is written to ``VAR`` and a compile-time definition with the same name as ``VAR`` is created if this
check succeeds. Setting ``LANGUAGE`` controls which compiler is used to perform the check. ``C`` uses the C
compiler and `CXX` uses the C++ compiler. If ``LANGUAGE`` is not set the C compiler is preferred over the
C++ compiler.

This function calls the check function and compile definitions function directly, so all features of those
commands are supported. For example, if ``LANGUAGE`` is not set, the C compiler is preferred over the C++
compiler just like |check_include_files|.

Examples
^^^^^^^^

Check if "stdlib.h" can be included into a source file using the C++ compiler and store the result in
STDLIB_EXISTS. A compile time definition with the value ``STDLIB_EXISTS=1` is created if the check was
successful.

.. code-block:: cmake

    helpers_check_includes(
        VAR STDLIB_EXISTS
        INCLUDES "stdlib.h"
        LANGUAGE CXX
    )

This causes the following program to exit with 0 if the include exists:

.. code-block:: c++

    int main() {
    #if defined(STDLIB_EXISTS)
        return 0;
    #else
        return 1;
    #endif
    }

.. |check_include_files| replace:: :command:`check_include_files <command:check_include_files>`
.. |add_compile_definitions| replace:: :command:`add_compile_definitions <command:add_compile_definitions>`
]]
function(helpers_check_includes)
    set(one_value_args VAR LANGUAGE)
    set(multi_value_args INCLUDES)
    cmake_parse_arguments("" "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    check_required_arg(_VAR)
    check_required_arg(_INCLUDES)

    _helpers_check_cached(${_VAR} "helpers_check_includes")

    list(JOIN _INCLUDES ", " includes)
    _helpers_status("helpers_check_includes" "checking ${includes} can be included" ADD_MESSAGES "language ${_LANGUAGE}")

    if(NOT DEFINED _LANGUAGE)
        check_include_files("${_INCLUDES}" "${_VAR}")
    elseif("${_LANGUAGE}" STREQUAL "CXX" OR "${_LANGUAGE}" STREQUAL "C")
        check_include_files("${_INCLUDES}" "${_VAR}" LANGUAGE "${_LANGUAGE}")
    else()
        _helpers_error("helpers_check_includes" "invalid language: ${_LANGUAGE}")
    endif()

    if(${_VAR})
        add_compile_definitions("${_VAR}=1")
    endif()
endfunction()

#[[.rst:
.. command:: helpers_add_dep

A wrapper function around |find_package| which links a found dependency to a target using
|target_link_libraries|.

.. code-block:: cmake

    helpers_add_dep(
        <target>
        <dependency>
        [VERSION version]
        [VISIBILITY visibility]
        [LINK_COMPONENTS link_components...]
        [FIND_PACKAGE_ARGS extra_args...]
    )

This function first calls |find_package| with the ``dependency`` and ``version`` if the dependency has not
already been found. It then determines the new components that the |find_package| call created by comparing
the state of the |IMPORTED_TARGETS| property before and after the call. Finally, iy links all the new items
to the ``target`` using |target_link_libraries| and the optionally specified ``VISIBILITY``.

Set ``LINK_COMPONENTS`` to manually specify which components should be linked to the target. This overrides
the components found using the |IMPORTED_TARGETS| detection logic described above. Some |find_package| modules
declare extra targets which aren't necessarily designed to be linked against. This option is useful if only
a subset of components declared by |find_package| should be linked to ``target``.

This function calls the |find_package| and |target_link_libraries| directly, so all features of those commands
are supported. Set ``FIND_PACKAGE_ARGS`` to pass additional arguments to |find_package|.

.. note:: ``LINK_COMPONENTS`` is not passed to |find_package|, instead use ``FIND_PACKAGE_ARGS`` to pass ``COMPONENTS``
that |find_package| should use.

Examples
^^^^^^^^

Find "ZLIB" with version 1 using |find_package| and link it as private to "target" using |target_link_libraries|.
Only the "ZLIB::ZLIB" component is linked to "target" and the dependency should be considered required and found
quietly.

.. code-block:: cmake

    helpers_add_dep(
        target
        ZLIB
        LINK_COMPONENTS ZLIB::ZLIB
        VERSION 1
        VISIBILITY PRIVATE
        FIND_PACKAGE_ARGS REQUIRED QUIET
    )

Find "Python"  using |find_package| and link it to "target" using |target_link_libraries|. The components that
are should be found are "Interpreter" and "Development" and all new targets declared by |find_package| are linked
to "target".

.. code-block:: cmake

    helpers_add_dep(
        target
        Python
        FIND_PACKAGE_ARGS COMPONENTS Interpreter Development
    )

.. |find_package| replace:: :command:`find_package <command:find_package>`
.. |target_link_libraries| replace:: :command:`target_link_libraries <command:target_link_libraries>`
.. |IMPORTED_TARGETS| replace:: :prop_dir:`IMPORTED_TARGETS <prop_dir:IMPORTED_TARGETS>`
]]
function(helpers_add_dep target dependency)
    set(one_value_args VERSION VISIBILITY)
    set(multi_value_args LINK_COMPONENTS FIND_PACKAGE_ARGS)
    cmake_parse_arguments("" "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    if(NOT ${dependency}_FOUND)
        get_property(before_importing DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY IMPORTED_TARGETS)

        find_package(${dependency} ${_VERSION} ${_FIND_PACKAGE_ARGS})

        # Set a property containing the imported targets of this find package call.
        get_property(after_importing DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY IMPORTED_TARGETS)
        list(REMOVE_ITEM after_importing "${before_importing}")

        if (after_importing)
            list(JOIN after_importing ", " imports)
            _helpers_status("helpers_add_dep" "found ${dependency} with components: ${imports}")
        endif()

        set(imported_targets_name "_program_dependencies_${dependency}")
        set_property(DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY "${imported_targets_name}" "${after_importing}")
    endif()

    # Override the components if linking manually.
    get_property(components DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY "${imported_targets_name}")
    if(DEFINED _LINK_COMPONENTS)
        set(components "${_LINK_COMPONENTS}")
    endif()

    if(DEFINED components)
        foreach(component IN LISTS components)
            target_link_libraries("${target}" "${_VISIBILITY}" "${component}")
            _helpers_status("helpers_add_dep" "component ${component} linked to ${target}")
        endforeach()

        _helpers_status(
            "helpers_add_dep"
            "linked ${dependency} to ${target}"
            ADD_MESSAGES "version ${_VERSION}" "visibility ${_VISIBILITY}"
        )
    endif()
endfunction()

#[[.rst:
.. command:: helpers_setup_gtest

A convenience function which links `GTest`_ and an optional testing library to a test executable
and calls |gtest_discover_tests| to find tests.

.. code-block:: cmake

    helpers_setup_gtest(
        <test_executable>
        [ADD_LIBRARY library]
    )

.. important:: This function does not call |enable_testing|.

Examples
^^^^^^^^

Discover tests for "test_executable" and link "additional_library" to the executable.

.. code-block:: cmake

    setup_gtest("test_executable" ADD_LIBRARY "additional_library")

.. _GTest: https://google.github.io/googletest/
.. |gtest_discover_tests| replace:: :command:`gtest_discover_tests <command:gtest_discover_tests>`
.. |enable_testing| replace:: :command:`enable_testing <command:enable_testing>`
]]
function(setup_gtest test_executable)
    set(one_value_args ADD_LIBRARY)
    cmake_parse_arguments("" "" "${one_value_args}" "" ${ARGN})

    target_link_libraries(${test_executable} PUBLIC ${_ADD_LIBRARY})

    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

    helpers_add_dep(
        ${test_executable}
        GTest
        LINK_COMPONENTS
        GTest::gtest
        GTest::gtest_main
        GTest::gmock
        VISIBILITY
        PUBLIC
        FIND_PACKAGE_ARGS
        REQUIRED
    )

    gtest_discover_tests(${test_executable})
endfunction()

#[[.rst:
check_required_arg
----------------

A macro which is used to check for required ``cmake_parse_arguments``
arguments.

.. code:: cmake

   check_required_arg(
       <ARG>
       <ARG_NAME>
   )

Check if ``ARG`` is defined, printing an error message with ``ARG_NAME``
and returning early if not.
]]
macro(check_required_arg ARG)
    string(REGEX REPLACE "^_" "" ARG_NAME ${ARG})
    if(NOT DEFINED ${ARG})
        message(FATAL_ERROR "cmake-helpers: required parameter ${ARG_NAME} not set")
        return()
    endif()
endmacro()

macro(header_file_set_variable_value line_end)
    foreach(file_name IN LISTS _TARGET_FILE_NAMES)
        file(STRINGS "${file_name}" lines)

        foreach(line IN LISTS lines)
            string(STRIP "${line}" line)
            set(variable_value "${variable_value}\"${line}\\n\"${line_end}\n")
        endforeach()
    endforeach()
    string(STRIP "${variable_value}" variable_value)

    # No line ending for last element. Escape to treat special characters.
    string(REGEX REPLACE "\\${line_end}$" "" variable_value "${variable_value}")
endmacro()

#[[.rst:
create_header_file
----------------

A function which creates a header file containing to contents of a ```file_name``.

.. code:: cmake

   create_header_file(
       <TARGET_FILE_NAME>
       <HEADER_FILE_NAME>
       <VARIABLE_NAME>
   )

Read ``TARGET_FILE_NAMES`` and create a string_view with their contents inside
``HEADER_FILE_NAME`` with the name ``VARIABLE_NAME`` and namespace ``NAMESPACE``.
]]
function(create_header_file header_file_name variable_name)
    set(one_value_args NAMESPACE OUTPUT_DIR TARGET VISIBILITY MODE)
    set(multi_value_args TARGET_FILE_NAMES)
    cmake_parse_arguments("" "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    check_required_arg(_TARGET_FILE_NAMES)

    # Get the correct define comment and namespace comment.
    string(TOUPPER "${header_file_name}" header_stem)
    string(REPLACE "." "_" header_stem ${header_stem})

    string(TOUPPER "${_NAMESPACE}" namespace_upper)
    string(REPLACE "::" "_" namespace_upper "${namespace_upper}")

    set(def_header "${namespace_upper}_${header_stem}")

    if(NOT DEFINED _MODE OR "${_MODE}" STREQUAL "constexpr_auto")
        _helpers_status("create_header_file" "using constexpr_auto")
        header_file_set_variable_value("")
        set(variable_declaration [[constexpr auto ${variable_name} = ${variable_value};]])
    elseif("${_MODE}" STREQUAL "const_char")
        header_file_set_variable_value("")
        _helpers_status("create_header_file" "using const_char")
        set(variable_declaration [[const char* ${variable_name} = ${variable_value};]])
    elseif("${_MODE}" STREQUAL "define_constant")
        # Double escape this to because it's entering a macro expansion.
        header_file_set_variable_value("\\\\")
        _helpers_status("create_header_file" "using define_constant")
        set(variable_declaration [[#define ${variable_name} ${variable_value}]])
    else()
        _helpers_error("create_header_file" "invalid mode: ${_MODE}")
    endif()

    if(DEFINED _NAMESPACE)
        set(namespace_start [[namespace ${_NAMESPACE} {]])
        set(namespace_end [[} // ${_NAMESPACE}]])
    endif()

    set(template [[
        // Auto-generated by my cmake-helpers
        #ifndef ${def_header}
        #define ${def_header}

        ${namespace_start}
        ${variable_declaration}
        ${namespace_end}

        #endif // ${def_header}
    ]])

    # Parse the file template as lines of strings.
    string(STRIP "${template}" template)
    string(REPLACE "\n" ";" lines "${template}")

    # Evaluate each line substituting the variables.
    foreach(line IN LISTS lines)
        string(STRIP "${line}" line)

        # Two layers of eval required.
        cmake_language(EVAL CODE "set(line \"${line}\")")
        cmake_language(EVAL CODE "set(line \"${line}\")")

        set(file "${file}${line}\n")
    endforeach()

    # Remove extra newlines.
    string(REGEX REPLACE "\n\n\n" "\n\n" file "${file}")

    if (NOT DEFINED _OUTPUT_DIR)
        set(_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
    endif ()

    cmake_path(APPEND _OUTPUT_DIR ${header_file_name} OUTPUT_VARIABLE output_file)
    file(WRITE "${output_file}" "${file}")

    _helpers_status("create_header_file" "generated output file")

    if (DEFINED _TARGET AND DEFINED _VISIBILITY)
        _helpers_status("create_header_file" "linking generated file to target ${_TARGET}")
        target_sources(${_TARGET} ${_VISIBILITY} ${output_file})
    endif ()

    set(cmake_helpers_ret ${_OUTPUT_DIR} PARENT_SCOPE)
endfunction()

#[[
Print a status message specific to the ``helpers.cmake`` module. Accepts multiple ``ADD_MESSAGES`` that print
additional ``key = value`` messages underneath the status.
]]
function(_helpers_status function message)
    set(multi_value_args ADD_MESSAGES)
    cmake_parse_arguments("" "" "" "${multi_value_args}" ${ARGN})

    set(message_prefix "cmake-helpers: ${function} - ")
    message(STATUS "${message_prefix}${message}")

    foreach(add_message IN LISTS _ADD_MESSAGES)
        string(REPLACE " " ";" add_message_list "${add_message}")

        list(LENGTH add_message_list add_message_length)
        if (${add_message_length} GREATER 1)
            list (GET add_message_list 0 key)
            list (GET add_message_list 1 value)

            if (NOT "${value}" STREQUAL "")
                message(STATUS "${message_prefix}    ${key} = ${value}")
            endif ()
        endif()
    endforeach()
endfunction()

#[[
Print an error message specific to the ``helpers.cmake`` module and exit early.
]]
macro(_helpers_error function message)
    message(FATAL_ERROR "cmake-helpers: ${function} - ${message}")
    return()
endmacro()

#[[
A macro which is used within ``helpers_check_includes`` and ``helpers_check_includes``
to check for a cached compile definition and return early if it is found.
]]
macro(_helpers_check_cached var status)
    if(${var})
        add_compile_definitions("${var}=${${var}}")

        _helpers_status(${status} "check result for \"${var}\" cached with value: ${${var}}")
        return()
    endif()
endmacro()
