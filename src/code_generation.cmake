include(utilities)

#[[.rst:
.. role:: cmake(code)
   :language: cmake
.. role:: cpp(code)
   :language: c++

Code Generation
***************

The code generation module has functions for generating code in C or C++. This includes code generation to embed resources,
serving as a replacement for the C23 `#embed`_ directive.
]]

#[[.rst:
helpers_embed
=============

Embeds a resource into source code as a variable or define macro. This function is similar to the C23 `#embed`_
directive, however the `#embed`_ directive should be preferred over :cmake:`helpers_embed` if it is available.

.. code-block:: cmake

    helpers_embed(
        <file>
        <variable>
        <EMBED embed_files...>
        [NAMESPACE namespace]
        [OUTPUT_DIR output_dir]
        [TARGET target]
        [VISIBILITY visibility]
        [AUTO_LITERAL | CHAR_LITERAL | BYTE_ARRAY | DEFINE_LITERAL | DEFINE_ARRAY]
    )

This function generates C or C++ code at the :cmake:`file` which embeds data contained within :cmake:`EMBED`
in a variable or preprocessor macro called :cmake:`variable`. If multiple files are specified in cmake:`EMBED`,
then they are all concatenated and embedded in the same :cmake:`variable`.

.. note:: This function cannot create multiple variables in the same file.

In order to control how the variable is created the mode should be specified as either :cmake:`AUTO_LITERAL`,
:cmake:`CHAR_LITERAL`, :cmake:`BYTE_ARRAY`, :cmake:`DEFINE_LITERAL` or :cmake:`DEFINE_ARRAY`. This function returns
an error if more than one of these modes if specified. The default mode is :cmake:`AUTO_LITERAL`.

:cmake:`AUTO_LITERAL` and :cmake:`CHAR_LITERAL` both define string literal variables with a null terminator, and a type of
:cpp:`constexpr auto` or :cpp:`const char *` respectively. :cmake:`BYTE_ARRAY` defines a byte array variable without a
null terminator, and a type of :cpp:`const uint8_t []`. :cmake:`DEFINE` defines a preprocessor macro.

The following table shows the generated code using these modes.

.. table:: :cmake:`helpers_embed` code generation modes.

    +-----------------------+-----------------------------------------------------------------------+
    | Mode                  | Generate Code                                                         |
    +=======================+=======================================================================+
    | :cmake:`AUTO_LITERAL` | .. code-block:: c++                                                   |
    |                       |    :caption: embed.h                                                  |
    |                       |                                                                       |
    |                       |    constexpr auto variable = "This is an embedded literal.\n";        |
    +-----------------------+-----------------------------------------------------------------------+
    | :cmake:`CHAR_LITERAL` | .. code-block:: c++                                                   |
    |                       |    :caption: embed.h                                                  |
    |                       |                                                                       |
    |                       |    const char* include_const_char = "This is an embedded literal.\n"; |
    +-----------------------+-----------------------------------------------------------------------+
    | :cmake:`BYTE_ARRAY`   | .. code-block:: c++                                                   |
    |                       |    :caption: embed.h                                                  |
    |                       |                                                                       |
    |                       |    constexpr auto variable = "This is an embedded literal.\n";        |
    +-----------------------+-----------------------------------------------------------------------+
    | :cmake:`DEFINE`       | .. code-block:: c++                                                   |
    |                       |    :caption: embed.h                                                  |
    |                       |                                                                       |
    |                       |    #define INCLUDE_DEFINE_CONSTANT "This is an embedded literal.\n"   |
    +-----------------------+-----------------------------------------------------------------------+

The variable definition can be surrounded by a namespace by specifying the :cmake:`NAMESPACE`. By default,
:cmake:`helpers_embed` places the generated file in |GENERATED_DIR|. :cmake:`OUTPUT_DIR` can be used
to change this location. If :cmake:`TARGET` is specified, then |target_sources| is used to add the generated
file to the :cmake:`TARGET` with :cmake:`VISIBILITY` visibility. The default visibility is :cmake:`"PRIVATE"`.

This function sets the a variable called :cmake:`helpers_ret` with :cmake:`PARENT_SCOPE` to the value of the :cmake:`OUTPUT_DIR`.
This can be used with |target_include_directories| to allow the source code to access the embedded resource.

Examples
--------

Embed a single file
^^^^^^^^^^^^^^^^^^^

This example embeds a single file into an auto literal and links the generated code to :cmake:`application`.

.. code-block:: cmake

   create_header_file(
       "include_constexpr_auto.h"
       "include_constexpr_auto"
       EMBED "embed_one.txt"
       TARGET application
   )
   target_include_directories(application PRIVATE ${cmake_helpers_ret})

This generates the following code, assuming :cmake:`embed_one.txt` contains ``"This is an embedded literal.\n"``:

.. code-block:: c++

   // Auto-generated by helpers_embed.
   #ifndef INCLUDE_CONSTEXPR_AUTO_H
   #define INCLUDE_CONSTEXPR_AUTO_H

   constexpr auto include_constexpr_auto = "This is an embedded literal.\n";

   #endif // INCLUDE_CONSTEXPR_AUTO_H

Embed multiple files
^^^^^^^^^^^^^^^^^^^^

This example embeds multiple files into a char literal and links the generated code to :cmake:`application`.

.. code-block:: cmake

   create_header_file(
       "include_const_char.h"
       "include_const_char"
       EMBED "embed_one.txt" "embed_two.txt"
       NAMESPACE "application::detail"
       TARGET application
   )
   target_include_directories(application PRIVATE ${cmake_helpers_ret})

This generates the following code, assuming :cmake:`embed_one.txt` contains ``"This is an embedded literal.\\n"`` and
:cmake:`embed_two.txt` contains ``"This is also an embedded literal.\\nWith multiple lines.\\n"``:

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
.. |GENERATED_DIR| replace:: :variable:`${CMAKE_CURRENT_BINARY_DIR}/generated <variable:CMAKE_CURRENT_BINARY_DIR>`
.. |target_sources| replace:: :command:`target_sources <command:target_sources>`
.. |target_include_directories| replace:: :command:`target_include_directories <command:target_include_directories>`
]]
function(helpers_embed file variable)
    set(options AUTO_LITERAL CHAR_LITERAL BYTE_ARRAY DEFINE)
    set(one_value_args NAMESPACE OUTPUT_DIR TARGET VISIBILITY)
    set(multi_value_args EMBED)
    cmake_parse_arguments("" "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

    helpers_required(_EMBED)
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
    string(REGEX REPLACE "\n\n+" "\n\n" generated "${generated}")

    if (NOT DEFINED _OUTPUT_DIR)
        set(_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
    endif ()

    cmake_path(APPEND _OUTPUT_DIR "${file}" OUTPUT_VARIABLE file)
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