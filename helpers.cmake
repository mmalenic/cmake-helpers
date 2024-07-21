include(CheckIncludeFiles)
include(CheckCXXSymbolExists)
include(CheckSymbolExists)

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
those functions are supported, such as setting the ``CMAKE_REQUIRED_*`` variables.

Example
^^^^^^^

Check if the "exit" symbol can be found after including "stdlib.h" in a source file using the C++ compiler.
The result of this check is stored in EXIT_EXISTS and a compile time definition with the value ``EXIT_EXISTS=1`
is created if the check was successful.

.. code-block:: cmake

helpers_check_symbol(SYMBOL "exit" FILES "stdlib.h" VAR EXIT_EXISTS)

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

    prepare_check_function(_VAR)

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
functions are supported. For example, if ``LANGUAGE`` is not set, the C compiler is preferred over the C++
compiler just like |check_include_files|.

Example
^^^^^^^

Check if "stdlib.h" can be included into a source file using the C++ compiler and store the result in
STDLIB_EXISTS. A compile time definition with the value ``STDLIB_EXISTS=1` is created if the check was
successful.

.. code-block:: cmake

helpers_check_includes(VAR STDLIB_EXISTS INCLUDES "stdlib.h" LANGUAGE CXX)

.. |check_include_files| replace:: :command:`check_include_files <command:check_include_files>`
.. |add_compile_definitions| replace:: :command:`add_compile_definitions <command:add_compile_definitions>`
]]
function(helpers_check_includes)
    set(one_value_args VAR LANGUAGE)
    set(multi_value_args INCLUDES)
    cmake_parse_arguments("" "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    check_required_arg(_VAR)
    check_required_arg(_INCLUDES)

    prepare_check_function(_VAR)

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
program_dependencies
----------------

Adds program dependencies using ``find_package`` and ``target_link_libraries``.

.. code:: cmake

   program_dependencies(
       <TARGET>
       <DEPENDENCY_NAME>
       VERSION [version]
       VISIBILITY [visibility]
       COMPONENTS [components...]
       LINK_COMPONENTS [link_components...]
   )

Finds a program dependency using ``find_package`` and then links it to an
existing target using ``target_link_libraries``. Treats all dependencies
and components as ``REQUIRED``. ``LINK_COMPONENTS`` optionally specifies the
the components that should be linked to the target, and if not present defaults
to ``COMPONENTS``. ``DIRECT_LINK`` specifies linking a dependency as
``${DEPENDENCY_NAME}`` rather than ``${DEPENDENCY_NAME}::${DEPENDENCY_NAME}``.
]]
function(program_dependencies TARGET DEPENDENCY_NAME)
    set(one_value_args VERSION VISIBILITY)
    set(multi_value_args LINK_COMPONENTS FIND_PACKAGE_ARGS)
    cmake_parse_arguments("" "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    if(NOT ${DEPENDENCY_NAME}_FOUND)
        get_property(before_importing DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY IMPORTED_TARGETS)

        find_package(${DEPENDENCY_NAME} ${_VERSION} ${_FIND_PACKAGE_ARGS})

        # Set a property containing the imported targets of this find package call.
        get_property(after_importing DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY IMPORTED_TARGETS)
        list(REMOVE_ITEM after_importing ${before_importing})

        if (after_importing)
            list(JOIN after_importing ", " imports)
            _helpers_status("program dependencies" "found ${DEPENDENCY_NAME} with components: ${imports}")
        endif()

        set(imported_targets_name "_program_dependencies_${DEPENDENCY_NAME}")
        set_property(DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY "${imported_targets_name}" "${after_importing}")

        get_property(name DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY "${imported_targets_name}")
    endif()

    # Override the components if linking manually.
    get_property(components DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY "${imported_targets_name}")
    if(DEFINED _LINK_COMPONENTS)
        set(components ${_LINK_COMPONENTS})
    endif()

    if(DEFINED components)
        list(LENGTH components length)
        if(${length} EQUAL 0)
            # Return early if there is nothing to link.
            return()
        endif()

        math(EXPR loop "${length} - 1")

        foreach(index RANGE 0 ${loop})
            list(GET components ${index} component)

            target_link_libraries(${TARGET} ${_VISIBILITY} ${component})
            _helpers_status("program dependencies" "component ${component} linked to ${TARGET}")
        endforeach()
    endif()

    _helpers_status(
            "program dependencies"
            "linked ${DEPENDENCY_NAME} to ${TARGET}"
            ADD_MESSAGES "version ${_VERSION}" "visibility ${_VISIBILITY}"
    )
endfunction()

#[[.rst:
prepare_check_function
----------------

A macro which is used within ``check_includes`` and ``check_symbol`` to set up
common logic and variables.

.. code:: cmake

   prepare_check_function(
       <RETURN_VAR>
       <INCLUDE_DIRS>
   )

Returns early if ``RETURN_VAR`` is defined. Sets ``CMAKE_REQUIRED_INCLUDES``
if ``INCLUDE_DIRS`` is defined. Assumes that ``RETURN_VAR`` and ``INCLUDE_DIRS``
is passed as a variable name and not a variable value.
]]
macro(prepare_check_function RETURN_VAR)
    if(DEFINED ${${RETURN_VAR}})
        add_compile_definitions("${${RETURN_VAR}}=1")

        _helpers_status("prepare_check_function" "check result for \"${${RETURN_VAR}}\" cached with value: ${${${RETURN_VAR}}}")
        return()
    endif()
endmacro()

#[[.rst:
setup_testing
----------------

A macro which sets up testing for an executable.

.. code:: cmake

   setup_testing(
       <TEST_EXECUTABLE_NAME>
       <LIBRARY_NAME>
   )

Enabled testing and links ``GTest`` to ``TEST_EXECUTABLE_NAME``. Links ``LIBRARY_NAME``
to ``TEST_EXECUTABLE_NAME``.
]]
macro(setup_testing TEST_EXECUTABLE_NAME LIBRARY_NAME)
    include(GoogleTest)

    target_link_libraries(${TEST_EXECUTABLE_NAME} PUBLIC ${LIBRARY_NAME})
    enable_testing()

    program_dependencies(
        ${TEST_EXECUTABLE_NAME}
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

    set(gtest_force_shared_crt
        ON
        CACHE BOOL "" FORCE
    )

    if(TARGET ${TEST_EXECUTABLE_NAME})
        gtest_discover_tests(${TEST_EXECUTABLE_NAME})
    endif()
endmacro()

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