include(utilities)

#[[.rst:
.. role:: cmake(code)
   :language: cmake
.. role:: cpp(code)
   :language: c++

Combinators
***********

The combinators module combines cmake functions and aim to reduce repetitive build configuration code.
]]

#[[.rst:
helpers_check_symbol
====================

A wrapper function around |check_cxx_symbol_exists|, or |check_symbol_exists| that adds compile time
definitions using |add_compile_definitions|.

.. code-block:: cmake

    helpers_check_symbol(
        SYMBOL <symbol>
        VAR <var>
        FILES [<file>...]
        [C]
    )

By default, this checks if the given :cmake:`SYMBOL` can be found after including :cmake:`FILES` using
|check_cxx_symbol_exists|. A cached result is written to :cmake:`VAR` and a compile-time definition with the
same name as :cmake:`VAR` is created if this check succeeds. Setting the :cmake:`C` flag uses |check_symbol_exists|
instead.

This function calls the check function and compile definitions function directly, so all features of
those commands are supported, such as setting the :cmake:`CMAKE_REQUIRED_*` variables.

Examples
--------

Check if a symbol exists in stdlib.h
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Checks if the :cpp:`"exit"` symbol can be found in :cpp:`"stdlib.h"`:

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

    helpers_required(_VAR)
    helpers_required(_SYMBOL)
    helpers_required(_FILES)

    _helpers_check_cached(${_VAR} "helpers_check_symbol")

    # Include guard is present.
    if(_C)
        _helpers_status("helpers_check_symbol" "using check_symbol_exists")
        include(CheckSymbolExists)
        check_symbol_exists("${_SYMBOL}" "${_FILES}" "${_VAR}")
    else()
        _helpers_status("helpers_check_symbol" "using check_cxx_symbol_exists")
        include(CheckCXXSymbolExists)
        check_cxx_symbol_exists("${_SYMBOL}" "${_FILES}" "${_VAR}")
    endif()

    if(${_VAR})
        add_compile_definitions("${_VAR}=1")
    endif()
endfunction()

#[[.rst:
helpers_check_includes
======================

A wrapper function around |check_include_files| which adds compile time definitions using
|add_compile_definitions|.

.. code-block:: cmake

    helpers_check_includes(
        VAR <var>
        INCLUDES <file>...
        [LANGUAGE C | CXX]
    )

By default, this checks that the given :cmake:`INCLUDES` can be included in a source file. A cached
result is written to :cmake:`VAR` and a compile-time definition with the same name as :cmake:`VAR` is created if this
check succeeds. Setting :cmake:`LANGUAGE` to :cmake:`C` or :cmake:`CXX` uses the C or C++ compiler respectively.
If :cmake:`LANGUAGE` is not set the C compiler is preferred if it is available.

This function calls |check_include_files| and |add_compile_definitions| directly, so all features of those
commands are supported.

Examples
--------

Check if stdlib.h can be included
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Check if ``"stdlib.h"`` can be included using the C++ compiler:

.. code-block:: cmake

    helpers_check_includes(
        VAR STDLIB_EXISTS
        INCLUDES "stdlib.h"
        LANGUAGE CXX
    )

This causes the following program to exit with 0 if the check succeeds:

.. code-block:: c++

    int main() {
    #if defined(STDLIB_EXISTS)
        return 0;
    #else
        return 1;
    #endif
    }

.. |check_include_files| replace:: :command:`check_include_files <command:check_include_files>`
]]
function(helpers_check_includes)
    set(one_value_args VAR LANGUAGE)
    set(multi_value_args INCLUDES)
    cmake_parse_arguments("" "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    helpers_required(_VAR)
    helpers_required(_INCLUDES)

    _helpers_check_cached(${_VAR} "helpers_check_includes")

    list(JOIN _INCLUDES ", " includes)
    _helpers_status(
        "helpers_check_includes" "checking ${includes} can be included" ADD_MESSAGES "language = ${_LANGUAGE}"
    )

    # Include guard is present.
    include(CheckIncludeFiles)
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
helpers_add_dep
===============

A wrapper function around |find_package| which links a dependency to a target using |target_link_libraries|.

.. code-block:: cmake

    helpers_add_dep(
        <target>
        <dependency>
        [VERSION version]
        [VISIBILITY visibility]
        [LINK_COMPONENTS link_components...]
        [FIND_PACKAGE_ARGS extra_args...]
    )

This function calls |find_package| with the :cmake:`dependency` and :cmake:`version` and determines the components
to add by comparing |IMPORTED_TARGETS| before and after calling |find_package|. All new components are linked
to the ``target`` using |target_link_libraries| with an optional :cmake:`VISIBILITY`.

Set :cmake:`LINK_COMPONENTS` to manually specify which components should be linked to the target, overriding
the components found using the |IMPORTED_TARGETS| logic. This option is useful if only a subset of components
declared by |find_package| should be linked to ``target``.

.. important:: Some |find_package| modules declare extra targets which may not be intended to be used in |target_link_libraries|.

This function calls the |find_package| and |target_link_libraries| directly, so all features of those commands
are supported. Set :cmake:`FIND_PACKAGE_ARGS` to pass additional arguments to |find_package|.

.. note:: :cmake:`LINK_COMPONENTS` is not passed to |find_package|, instead use :cmake:`FIND_PACKAGE_ARGS` to specify
          :cmake:`COMPONENTS` that |find_package| should use.

Examples
--------

Find ZLIB and link to a target
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This example finds :cmake:`ZLIB` and links :cmake:`ZLIB::ZLIB` as private dependency to :cmake:`target`:

.. code-block:: cmake

    helpers_add_dep(
        target
        ZLIB
        LINK_COMPONENTS ZLIB::ZLIB
        VERSION 1
        VISIBILITY PRIVATE
        FIND_PACKAGE_ARGS REQUIRED QUIET
    )

Find a only some components
^^^^^^^^^^^^^^^^^^^^^^^^^^^

This finds the :cmake:`Interpreter` and :cmake:`Development` components of :cmake:`Python` and links all found components
to :cmake`target`:

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
        get_property(
            before_importing
            DIRECTORY "${CMAKE_SOURCE_DIR}"
            PROPERTY IMPORTED_TARGETS
        )

        find_package(${dependency} ${_VERSION} ${_FIND_PACKAGE_ARGS})

        # Set a property containing the imported targets of this find package call.
        get_property(
            after_importing
            DIRECTORY "${CMAKE_SOURCE_DIR}"
            PROPERTY IMPORTED_TARGETS
        )
        list(REMOVE_ITEM after_importing "${before_importing}")

        if(after_importing)
            list(JOIN after_importing ", " imports)
            _helpers_status("helpers_add_dep" "found ${dependency} with components: ${imports}")
        endif()

        set(imported_targets_name "_program_dependencies_${dependency}")
        set_property(DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY "${imported_targets_name}" "${after_importing}")
    endif()

    # Override the components if linking manually.
    get_property(
        components
        DIRECTORY "${CMAKE_SOURCE_DIR}"
        PROPERTY "${imported_targets_name}"
    )
    if(DEFINED _LINK_COMPONENTS)
        set(components "${_LINK_COMPONENTS}")
    endif()

    if(DEFINED components)
        foreach(component IN LISTS components)
            target_link_libraries("${target}" "${_VISIBILITY}" "${component}")
            _helpers_status("helpers_add_dep" "component ${component} linked to ${target}")
        endforeach()

        _helpers_status(
            "helpers_add_dep" "linked ${dependency} to ${target}" ADD_MESSAGES "version = ${_VERSION}"
            "visibility = ${_VISIBILITY}"
        )
    endif()
endfunction()

#[[.rst:
helpers_setup_gtest
===================

A convenience function which links `GTest`_ and an optional testing library to a test executable
and calls |gtest_discover_tests| to find tests.

.. code-block:: cmake

    helpers_setup_gtest(
        <test_executable>
        [ADD_LIBRARIES add_libraries...]
    )

The :cmake:`test_executable` specifies the  executable to discover tests with and :cmake:`ADD_LIBRARIES` specifies
additional libraries which should be linked to :cmake:`test_executable`.

.. note:: This function calls |enable_testing|.

Examples
--------

Discover tests for an executable
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This discovers tests for :cmake:`test_executable` and links :cmake:`additional_library` to the executable.

.. code-block:: cmake

    setup_gtest(
        "test_executable"
        ADD_LIBRARIES "additional_library"
    )

.. _GTest: https://google.github.io/googletest
.. |gtest_discover_tests| replace:: :command:`gtest_discover_tests <command:gtest_discover_tests>`
.. |enable_testing| replace:: :command:`enable_testing <command:enable_testing>`
]]
function(setup_gtest test_executable)
    set(multi_value_args ADD_LIBRARIES)
    cmake_parse_arguments("" "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    foreach(library IN LISTS _ADD_LIBRARIES)
        target_link_libraries(${test_executable} PUBLIC ${library})
    endforeach()

    enable_testing()
    set(gtest_force_shared_crt
        ON
        CACHE BOOL "" FORCE
    )

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

    # Include guard is present.
    include(GoogleTest)
    gtest_discover_tests(${test_executable})
endfunction()

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
