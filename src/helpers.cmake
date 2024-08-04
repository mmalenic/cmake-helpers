#[[.rst:
.. role:: cmake(code)
   :language: cmake
.. role:: shell(code)
   :language: shell

cmake-helpers
*************

A small collection of CMake build code which adds some missing functionality and reduces repetitive build
configurations.

This repository contains a C23 `#embed`_ replacement, functions for better dependency management, utilities for
defining required args and enums, and combinator functions for |check_command| commands.

Usage
=====

To use this library, you can use CMake's |fetch_content| to import the project. All library
commands are available after including with a :cmake:`helpers_` prefix:

.. code-block:: cmake

   include(FetchContent)

   FetchContent_Declare(
        helpers
        GIT_REPOSITORY https://github.com/mmalenic/cmake-helpers
        GIT_TAG 0.1.0
   )
   FetchContent_MakeAvailable(helpers)

   include(helpers)

Alternatively, copy and paste the code in the `src`_ directory
and include the library using :cmake:`include(helpers)`.

Why does this project exist?
============================

The motivation behind this project is to define a common set of CMake functions that I use for a variety of C++ projects.

There are countless CMake "helper"-style libraries. See a list of some of the `here`_.
This project does not aim to replace these, however it does contain some code which existing libraries lack,
such as interactions with the CMake |check_command| commands.

Development
===========

This project contains a set of unit tests for the :cmake:`helpers` commands. These can be run using `pytest`_ and `poetry`_.
After initializing the poetry project, run the tests using pytest:

.. code-block:: shell

   pytest

The documentation for this project (including this README) is made using `sphinx`_, and published to github pages.
To generate documentation, run the following in the `docs`_ directory to create a static page:

.. code-block:: shell

   make html

Run the following to update this ``README.md``:

.. code-block:: shell

   make readme

Contributions are welcome. Feel free to open any pull requests or issues.

Licence
=======

This project is licensed under the MIT `licence`_.

.. |fetch_content| replace:: :module:`FetchContent <module:FetchContent>`
.. |check_command| replace:: :command:`check_ <command:check_symbol_exists>`

.. _#embed: https://en.cppreference.com/w/c/preprocessor/embed
.. _here: https://github.com/onqtam/awesome-cmake
.. _src: https://github.com/mmalenic/cmake-helpers/tree/main/src
.. _docs: https://github.com/mmalenic/cmake-helpers/tree/main/docs
.. _pytest: https://docs.pytest.org/en/stable/
.. _poetry: https://python-poetry.org/
.. _sphinx: https://www.sphinx-doc.org/en/master/
.. _licence: https://github.com/mmalenic/cmake-helpers/blob/main/LICENSE
]]

include(code_generation)
include(combinators)
include(utilities)

#[[
Print a status message specific to the ``helpers.cmake`` module. Accepts multiple ``ADD_MESSAGES`` that print
additional ``key = value`` messages underneath the status.
]]
function(_helpers_status function message)
    set(multi_value_args ADD_MESSAGES)
    cmake_parse_arguments("" "" "" "${multi_value_args}" ${ARGN})

    set(function_prefix "${function} - ")
    string(LENGTH "${function_prefix}" function_prefix_length)
    string(REPEAT " " "${function_prefix_length}" function_spaces)

    set(helpers_prefix "cmake-helpers: ")
    message(STATUS "${helpers_prefix}${function_prefix}${message}")

    foreach(add_message IN LISTS _ADD_MESSAGES)
        if (NOT add_message MATCHES "= $" AND NOT add_message MATCHES "^ =")
            message(STATUS "${helpers_prefix}${function_spaces}${add_message}")
        endif()
    endforeach()
endfunction()

#[[
Print an error message specific to the ``helpers.cmake`` module and exit early in the calling scope.
]]
macro(_helpers_error function message)
    message(FATAL_ERROR "cmake-helpers: ${function} - ${message}")
    return()
endmacro()
