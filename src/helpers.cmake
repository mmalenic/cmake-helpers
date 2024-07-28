include(code_generation)
include(combinators)
include(utilities)

#[[
Used to define a variable value when generating code for embedding files into source code.
The ``line_end`` specifies the line ending for each line of the input, for example, an extra backslash.
]]
macro(_helpers_embed_lines line_end hex)
    foreach(file_name IN LISTS _EMBED)
        if(${hex})
            # Read as hex and split into bytes.
            file(READ "${file_name}" lines_hex HEX)
            string(REGEX MATCHALL "../.." lines ${lines_hex})
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
