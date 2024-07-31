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
