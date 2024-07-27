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

    _helpers_required(_VAR)
    _helpers_required(_SYMBOL)
    _helpers_required(_FILES)

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

    _helpers_required(_VAR)
    _helpers_required(_INCLUDES)

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
        [ADD_LIBRARIES add_libraries...]
    )

The ``test_executable`` specifies which test executable to discover tests on and ``ADD_LIBRARIES`` specifies
any additional libraries which should be publically linked to the ``test_executable``.

.. important:: This function does not call |enable_testing|.

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
.. command:: helpers_embed

Embeds a resource into source code as a variable or preprocessor define directive.
This function is similar to the C23 `#embed`_ directive, and can serve as a replacement until
it is available. The `#embed`_ directive should be preferred over ``helpers_embed`` if it is available.

.. code-block:: cmake

    helpers_embed(
        <file>
        <variable>
        <EMBED embed_files...>
        [NAMESPACE namespace]
        [OUTPUT_DIR output_dir]
        [TARGET target]
        [VISIBILITY visibility]
        [AUTO_LITERAL | CHAR_LITERAL | AUTO_ARRAY | BYTE_ARRAY | DEFINE_LITERAL | DEFINE_ARRAY]
    )

This function generates C or C++ code at the ``file`` which embeds data contained within ``EMBED``
in a variable or preprocessor macro called ``variable``. If multiple files are specified in ``EMBED``,
then they are all concatenated and embedded in the same ``variable``.

.. note:: This function cannot create multiple variables in the same file.

In order to control how the variable is created a resource definition mode should be specified as either
``AUTO_LITERAL``, ``CHAR_LITERAL``, ``AUTO_ARRAY``, ``BYTE_ARRAY``, ``DEFINE_LITERAL`` or ``DEFINE_ARRAY``.
This function returns are error if more than one of these modes if specified. The default mode is ``AUTO_LITERAL``.

.. role:: cpp_type(code)
   :language: c++

``AUTO_LITERAL`` and ``CHAR_LITERAL`` both define string literals with a null terminator as the variable, either as
a :cpp_type:`constexpr auto` or :cpp_type:`const char *` respectively. ``AUTO_ARRAY`` and ``BYTE_ARRAY`` both define
arrays without a null terminator as the variable, either as :cpp_type:`constexpr auto` or :cpp_type:`const uint8_t *`
respectively. ``DEFINE`` defines a preprocessor macro string.

The following table describes how each mode defines the embedded resource in "embed.h" where the ``variable`` is
"variable" and the ``EMBED`` resource is "This is an embedded literal.\\n":

.. table:: ``helpers_embed`` resource definition modes

    +------------------+-----------------------------------------------------------------------+
    | Mode             | Generate Code                                                         |
    +==================+=======================================================================+
    | ``AUTO_LITERAL`` | .. code-block:: c++                                                   |
    |                  |    :caption: embed.h                                                  |
    |                  |                                                                       |
    |                  |    constexpr auto variable = "This is an embedded literal.\n";        |
    +------------------+-----------------------------------------------------------------------+
    | ``CHAR_LITERAL`` | .. code-block:: c++                                                   |
    |                  |    :caption: embed.h                                                  |
    |                  |                                                                       |
    |                  |    const char* include_const_char = "This is an embedded literal.\n"; |
    +------------------+-----------------------------------------------------------------------+
    | ``AUTO_ARRAY``   | .. code-block:: c++                                                   |
    |                  |    :caption: embed.h                                                  |
    |                  |                                                                       |
    |                  |    constexpr auto variable = "This is an embedded literal.\n";        |
    +------------------+-----------------------------------------------------------------------+
    | ``BYTE_ARRAY``   | .. code-block:: c++                                                   |
    |                  |    :caption: embed.h                                                  |
    |                  |                                                                       |
    |                  |    constexpr auto variable = "This is an embedded literal.\n";        |
    +------------------+-----------------------------------------------------------------------+
    | ``DEFINE``       | .. code-block:: c++                                                   |
    |                  |    :caption: embed.h                                                  |
    |                  |                                                                       |
    |                  |    #define INCLUDE_DEFINE_CONSTANT "This is an embedded literal.\n"   |
    +------------------+-----------------------------------------------------------------------+

The variable definition can be surrounded by a namespace by defining the namespace name in ``NAMESPACE``. By default,
``helpers_embed`` places the generated file in ``${|CMAKE_CURRENT_BINARY_DIR|}/generated``. ``OUTPUT_DIR`` can be used
to change this location. If ``TARGET`` is specified, then |target_sources| is used to add the generated
file to the ``TARGET`` with "PRIVATE" visibility. ``VISIBILITY`` can be used to change the default visibility.

This function sets the a variable called ``helpers_ret`` with ``PARENT_SCOPE`` to the value of the ``OUTPUT_DIR`` when it
finished. This can be used together with |target_include_directories| to allow the source code to access the embedded variable.

Examples
^^^^^^^^

Generate a file called ``include_constexpr_auto.h`` with a variable of the same name with the contents of ``embed_one.txt``.
The target ``application`` has the generated source added, and |target_include_directories| is used to access the variable.

.. code-block:: cmake

   create_header_file(
       "include_constexpr_auto.h"
       "include_constexpr_auto"
       EMBED "embed_one.txt"
       TARGET application
   )
   target_include_directories(application PRIVATE ${cmake_helpers_ret})

This generates the following code, assuming ``embed_one.txt`` contains "This is an embedded literal.\n":

.. code-block:: c++

   // Auto-generated by helpers_embed.
   #ifndef INCLUDE_CONSTEXPR_AUTO_H
   #define INCLUDE_CONSTEXPR_AUTO_H

   constexpr auto include_constexpr_auto = "This is an embedded literal.\n";

   #endif // INCLUDE_CONSTEXPR_AUTO_H

Generate a file called ``include_const_char.h`` with a variable of the same name with the contents of ``embed_one.txt``
and ``embed_two.txt``. The variable mode is ``CHAR_LITERAL`` and a namespace is defined. The target ``application``
has the generated source added, and |target_include_directories| is used to access the variable.

.. code-block:: cmake

   create_header_file(
       "include_const_char.h"
       "include_const_char"
       EMBED "embed_one.txt" "embed_two.txt"
       NAMESPACE "application::detail"
       TARGET application
   )

This generates the following code, assuming ``embed_one.txt`` contains "This is an embedded literal.\\n" and
``embed_two.txt`` contains "This is also an embedded literal.\\nWith multiple lines.\\n":

.. code-block:: c++

   // Auto-generated by helpers_embed.
   #ifndef APPLICATION_DETAIL_INCLUDE_CONST_CHAR_H
   #define APPLICATION_DETAIL_INCLUDE_CONST_CHAR_H

   namespace application::detail {
   const char* include_const_char_multi = "This is an embedded literal.\n"
   "This is also an embedded literal.\n"
   "With multiple lines.\n";
   } // application::detail

   #endif // APPLICATION_DETAIL_INCLUDE_CONST_CHAR_H

.. _#embed: https://en.cppreference.com/w/c/preprocessor/embed
.. |CMAKE_CURRENT_BINARY_DIR| replace:: :variable:`CMAKE_CURRENT_BINARY_DIR <variable:CMAKE_CURRENT_BINARY_DIR>`
.. |target_sources| replace:: :command:`target_sources <command:target_sources>`
.. |target_include_directories| replace:: :command:`target_include_directories <command:target_include_directories>`
]]
function(helpers_embed file variable)
    set(options AUTO_LITERAL CHAR_LITERAL BYTE_ARRAY DEFINE)
    set(one_value_args NAMESPACE OUTPUT_DIR TARGET VISIBILITY)
    set(multi_value_args EMBED)
    cmake_parse_arguments("" "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

    _helpers_required(_EMBED)
    helpers_enum(_AUTO_LITERAL _CHAR_LITERAL _AUTO_ARRAY _BYTE_ARRAY _DEFINE)

    # Get the include guard and namespace comment.
    string(TOUPPER "${file}" header_stem)
    string(REPLACE "." "_" def_header ${header_stem})

    string(TOUPPER "${_NAMESPACE}" namespace_upper)
    string(REPLACE "::" "_" namespace_upper "${namespace_upper}")

    if(_CHAR_LITERAL)
        _helpers_embed_lines("" FALSE)
        _helpers_status("helpers_embed" "defining char literal")
        set(variable_declaration [[const char* ${variable} = ${value};]])
    elseif(_BYTE_ARRAY)
        _helpers_embed_lines("," TRUE)
        _helpers_status("helpers_embed" "defining byte array")
        set(include "#include <stdint.h>")
        set(variable_declaration [[const uint8_t ${variable}[] = ${value};]])
    elseif(_DEFINE)
        # Double escape this to because it's entering a macro expansion.
        _helpers_embed_lines("\\\\" FALSE)
        _helpers_status("helpers_embed" "defining preprocessor macro")
        set(variable_declaration [[#define ${variable} ${value}]])
    else()
        # Default case is ``AUTO_LITERAL``.
        _helpers_status("helpers_embed" "defining auto literal")
        _helpers_embed_lines("" FALSE)
        set(variable_declaration [[constexpr auto ${variable} = ${value};]])
    endif()

    if(DEFINED _NAMESPACE)
        set(namespace_start [[namespace ${_NAMESPACE} {]])
        set(namespace_end [[} // ${_NAMESPACE}]])
        set(def_header "${namespace_upper}_${def_header}")
    endif()

    set(template [[
        // Auto-generated by helpers_embed.
        #ifndef ${def_header}
        #define ${def_header}

        ${include}

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

        set(generated "${generated}${line}\n")
    endforeach()

    # Remove extra newlines.
    string(REGEX REPLACE "\n\n\n" "\n\n" generated "${generated}")

    if (NOT DEFINED _OUTPUT_DIR)
        set(_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
    endif ()

    cmake_path(APPEND _OUTPUT_DIR ${file} OUTPUT_VARIABLE file)
    file(WRITE "${file}" "${generated}")

    _helpers_status("helpers_embed" "generated output file at ${file}")

    if (DEFINED _TARGET)
        if (NOT DEFINED _VISIBILITY)
            set(_VISIBILITY PRIVATE)
        endif()

        _helpers_status("helpers_embed" "linking generated file to target ${_TARGET}")
        target_sources(${_TARGET} ${_VISIBILITY} ${file})
    endif ()

    set(cmake_helpers_ret ${_OUTPUT_DIR} PARENT_SCOPE)
endfunction()

#[[.rst
.. command:: helpers_enum

A utility macro which checks whether only one out of a set of variables is defined and returns an error if not more than
one is defined. This is useful to define enum value option which can only have one out of a set of options defined at a time.

.. code-block:: cmake

    helpers_enum(
        <enums...>
    )

This macro returns an prints an error message if more than one variable is defined in ``enums``. It also returns
early out of the scope of the calling code.

Examples
^^^^^^^^

Check if only one variable out of ``A``, ``B``, and ``C`` is defined and return early if more than one is defined.

.. code-block:: cmake

   helpers_enum(
       A
       B
       C
   )
]]
macro(helpers_enum enums)
    foreach(enum IN LISTS ${enums})
        if(DEFINED ${enum})
            list(APPEND _helpers_enum_defined ${enum})
        endif()
    endforeach()

    list(LENGTH _helpers_enum_defined _helpers_enum_n_defined)
    if(_helpers_enum_n_defined GREATER 1)
        _helpers_error("helpers_enum" "there should not be more than one enum option")

        list(JOIN _helpers_enum_defined ", " _helpers_enum_defined_formatted)
        _helpers_error("helpers_enum" "currently defined: ${_helpers_enum_defined_formatted}")

        return()
    endif()
endmacro()

#[[
Used to define a variable value when generating code for embedding files into source code.
The ``line_end`` specifies the line ending for each line of the input, for example, an extra backslash.
]]
macro(_helpers_embed_lines line_end hex)
    foreach(file_name IN LISTS _EMBED)
        if(${hex})
            # Read as hex and split into bytes.
            file(READ "${file_name}" lines_hex HEX)
            string(REGEX MATCHALL ".." lines ${lines_hex})
            set(surround_start "0x")
            set(enclose_start "{")
            set(enclose_end "}")
        else()
            # Read as lines.
            file(STRINGS "${file_name}" lines)
            set(surround_start "\"")
            set(surround_end "\\n\"")
        endif()

        foreach(line IN LISTS lines)
            string(STRIP "${line}" line)
            set(value "${value}${surround_start}${line}${surround_end}${line_end}\n")
        endforeach()
    endforeach()
    string(STRIP "${enclose_start}${value}${enclose_end}" value)

    # No line ending for last element. Escape to treat special characters.
    string(REGEX REPLACE "\\${line_end}$" "" value "${value}")
endmacro()

#[[
Checks that a required argument parsed by ``cmake_parse_arguments`` is set. This assumes that
the argument which is being checked is prefixed with ``_``.
]]
macro(_helpers_required arg)
    string(REGEX REPLACE "^_" "" arg_name ${arg})
    if(NOT DEFINED ${arg})
        message(FATAL_ERROR "cmake-helpers: required parameter ${arg_name} not set")
        return()
    endif()
endmacro()

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
