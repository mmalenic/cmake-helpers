#include <iostream>

#include "include_const_char.h"
#include "include_const_char_multi.h"
#include "include_const_char_namespace.h"
#include "include_constexpr_auto.h"
#include "include_constexpr_auto_multi.h"
#include "include_constexpr_auto_namespace.h"
#include "include_define_constant.h"
#include "include_define_constant_multi.h"

int main() {
    std::cout << include_const_char;
    std::cout << application::detail::include_const_char_namespace;
    std::cout << include_constexpr_auto;
    std::cout << application::detail::include_constexpr_auto_namespace;
    std::cout << application::detail::include_constexpr_auto_namespace;
    std::cout << INCLUDE_DEFINE_CONSTANT;

    std::cout << application::detail::include_const_char_multi;
    std::cout << application::detail::include_constexpr_auto_multi;
    std::cout << INCLUDE_DEFINE_CONSTANT_MULTI;
}
