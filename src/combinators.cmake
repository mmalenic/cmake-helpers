include(utilities)

#[[.rst
Combinators
***********

The combinators module combines cmake functions to create combination patterns which can be common to builds. For
example, `helpers_add_dep`_ combines |find_package| and |target_link_libraries| in order to link a dependency to a
target.

In general, combinators aim to reduce repetitive and boilerplate build configuration code.
]]

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

    helpers_required(_VAR)
    helpers_required(_INCLUDES)

    _helpers_check_cached(${_VAR} "helpers_check_includes")

    list(JOIN _INCLUDES ", " includes)
    _helpers_status("helpers_check_includes" "checking ${includes} can be included" ADD_MESSAGES "language = ${_LANGUAGE}")

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
            ADD_MESSAGES "version = ${_VERSION}" "visibility = ${_VISIBILITY}"
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
        [ADD_LIBRARIES add_libraries...]
    )

The ``test_executable`` specifies which test executable to discover tests on and ``ADD_LIBRARIES`` specifies
any additional libraries which should be publically linked to the ``test_executable``.

.. note:: This function calls |enable_testing|.

Examples
^^^^^^^^

Discover tests for "test_executable" and link "additional_library" to the executable.

.. code-block:: cmake

    setup_gtest("test_executable" ADD_LIBRARIES "additional_library")

.. _GTest: https://google.github.io/googletest
.. |gtest_discover_tests| replace:: :command:`gtest_discover_tests <command:gtest_discover_tests>`
.. |enable_testing| replace:: :command:`enable_testing <command:enable_testing>`
]]
function(setup_gtest test_executable)
    set(multi_value_args ADD_LIBRARIES)
    cmake_parse_arguments("" "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    foreach(library IN LISTS _ADD_LIBRARIES)
        target_link_libraries(${test_executable} PUBLIC ${library})
    endforeach ()

    enable_testing()
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

    # Include guard is present.
    include(GoogleTest)
    gtest_discover_tests(${test_executable})
endfunction()
