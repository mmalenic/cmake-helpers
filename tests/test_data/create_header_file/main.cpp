#include <iostream>
#include "include_constexpr_auto_namespace.h"

int main() {
    std::cout << application::detail::include;
}
