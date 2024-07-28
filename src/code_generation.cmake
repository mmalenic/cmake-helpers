include(utilities)

#[[.rst
Code Generation
***************

The code generation module has functions for generates code in C or C++. Currently,there is one function which
embeds any resource as a string literal or binary array into C or C++ code. This serves as a replacement of the
C23 `#embed`_ directive.
]]

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

    helpers_required(_EMBED)
    helpers_enum(_AUTO_LITERAL _CHAR_LITERAL _AUTO_ARRAY _BYTE_ARRAY _DEFINE)

    # Get the include guard and namespace comment.
    string(TOUPPER "${file}" header_stem)
    string(REPLACE ".." "_" def_header ${header_stem})

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
