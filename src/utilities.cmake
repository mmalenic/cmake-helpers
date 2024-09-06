#[[.rst:
.. role:: cmake(code)
   :language: cmake
.. role:: cpp(code)
   :language: c++

Utilities
*********

The utilities module contains miscellaneous commands such as for defining enums or required arguments.
]]

#[[.rst:
toolbelt_enum
=============

A macro which checks whether only one out of a set of variables is truthy and returns an error if not.
This is useful to define enum options which can be one out of a set of defined values.

.. code-block:: cmake

    toolbelt_enum(
        <variables...>
    )

This macro returns an error in the scope of the calling code, if more than one variable in :cmake:`variables`
evaluates to true. It assumes that variables prefixed with :cmake:`_` should be printed without this prefix which is
useful to properly format arguments parsed by |cmake_parse_arguments|.

Examples
--------

Check if an enum is set
^^^^^^^^^^^^^^^^^^^^^^^

This checks if only one out of :cmake:`A`, :cmake:`B`, and :cmake:`C` is truthy and returns early if not.

.. code-block:: cmake

   toolbelt_enum(
       A
       B
       C
   )

.. |cmake_parse_arguments| replace:: :command:`cmake_parse_arguments <command:cmake_parse_arguments>`
]]
macro(toolbelt_enum)
    # Grab all the arguments.
    set(enums ${ARGN})

    # Find the defined values.
    foreach(enum IN LISTS enums)
        if(${enum})
            string(REGEX REPLACE "^_" "" enum_name ${enum})
            list(APPEND _toolbelt_enum_defined ${enum_name})
        endif()
    endforeach()

    list(LENGTH _toolbelt_enum_defined _toolbelt_enum_n_defined)
    if(_toolbelt_enum_n_defined GREATER 1)
        list(JOIN _toolbelt_enum_defined ", " _toolbelt_enum_defined_formatted)
        _toolbelt_error("toolbelt_enum" "more than one variable defined: ${_toolbelt_enum_defined_formatted}")
    endif()
endmacro()

#[[.rst:
toolbelt_required
=================

A macro which checks whether an argument is truthy and returns an error if not. This can be used to
confirm the presence of arguments parsed by |cmake_parse_arguments|.

.. code-block:: cmake

    toolbelt_required(
        <arg>
    )

This macro returns an error in the scope of the calling code if :cmake:`arg` is not truthy.

Examples
--------

Check if an argument is set
^^^^^^^^^^^^^^^^^^^^^^^^^^^

This checks if :cmake:`arg` is defined and evaluates to true:

.. code-block:: cmake

   toolbelt_required(
       arg
   )
]]
macro(toolbelt_required arg)
    string(REGEX REPLACE "^_" "" arg_name ${arg})
    if(NOT ${arg})
        _toolbelt_error("toolbelt_required" "required parameter ${arg_name} not set")
    endif()
endmacro()
