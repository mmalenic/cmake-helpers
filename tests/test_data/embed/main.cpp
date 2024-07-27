#include <iostream>

#include "auto_literal.h"
#include "auto_literal_multi.h"
#include "auto_literal_namespace.h"
#include "byte_array.h"
#include "byte_array_multi.h"
#include "byte_array_namespace.h"
#include "const_literal.h"
#include "const_literal_multi.h"
#include "const_literal_namespace.h"
#include "define.h"
#include "define_multi.h"


int main() {
    std::cout << auto_literal;
    std::cout << const_literal;
    std::cout << std::string{
        reinterpret_cast<const char *>(byte_array),
        sizeof(byte_array)
    };
    std::cout << DEFINE;

    std::cout << application::detail::auto_literal_namespace;
    std::cout << application::detail::const_literal_namespace;
    std::cout << std::string{
        reinterpret_cast<const char *>(application::detail::byte_array_namespace),
        sizeof(application::detail::byte_array_namespace)
    };

    std::cout << application::detail::auto_literal_multi;
    std::cout << application::detail::const_literal_multi;
    std::cout << application::detail::byte_array_multi;
    std::cout << DEFINE_MULTI;
}
