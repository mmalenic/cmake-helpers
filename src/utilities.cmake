#[[.rst:
Utilities
*********

The utilities module contains a few utility commands for common operations like definition enums or required arguments.
]]

#[[.rst:
helpers_enum
============

A utility macro which checks whether only one out of a set of variables is truthy and returns an error if not.
This is useful to define enum value options which can only have one out of a set of options defined at a time.

.. code-block:: cmake

    helpers_enum(
        <variables...>
    )

This macro returns an prints an error message if more than one variable in ``variables`` evaluates to true in an if
statement. It returns early if not, in the scope of the calling code. It assumes that variables prefixed with "_"
should be printed without this prefix. This behaviour is useful to properly format prefixed arguments parsed by
|cmake_parse_arguments|.

Examples
^^^^^^^^

Check if only one variable out of ``A``, ``B``, and ``C`` is truthy and return early if not.

.. code-block:: cmake

   helpers_enum(
       A
       B
       C
   )

.. |cmake_parse_arguments| replace:: :command:`cmake_parse_arguments <command:cmake_parse_arguments>`
]]
macro(helpers_enum)
    # Grab all the arguments.
    set(enums ${ARGN})

    # Find the defined values.
    foreach(enum IN LISTS enums)
        if(${enum})
            string(REGEX REPLACE "^_" "" enum_name ${enum})
            list(APPEND _helpers_enum_defined ${enum_name})
        endif()
    endforeach()

    list(LENGTH _helpers_enum_defined _helpers_enum_n_defined)
    if(_helpers_enum_n_defined GREATER 1)
        list(JOIN _helpers_enum_defined ", " _helpers_enum_defined_formatted)
        _helpers_error("helpers_enum" "more than one variable defined: ${_helpers_enum_defined_formatted}")
    endif()
endmacro()

#[[.rst:
helpers_required
================

A utility macro which checks whether an argument is truthy and returns an error if not. This is useful to
confirm the presence of arguments parsed by |cmake_parse_arguments|.

.. code-block:: cmake

    helpers_required(
        <arg>
    )

This macro checks if ``arg`` is truthy and returns early in the scope of the calling code if not. It assumes that
variables prefixed with "_" should be printed without this prefix. This behaviour is useful to properly format prefixed
arguments parsed by |cmake_parse_arguments|.

Examples
^^^^^^^^

Check if ``arg`` is defined and return early if it is not.

.. code-block:: cmake

   helpers_required(
       arg
   )
]]
macro(helpers_required arg)
    string(REGEX REPLACE "^_" "" arg_name ${arg})
    if(NOT ${arg})
        _helpers_error("helpers_required" "required parameter ${arg_name} not set")
    endif()
endmacro()
