from subprocess import CalledProcessError, run

import pytest

from tests.fixtures import program_dependencies, run_cmake_with_assert


def test_program_dependencies(program_dependencies, capfd):
    """
    Test that check symbols compiles an existing symbol.
    """
    run_cmake_with_assert(capfd, ["cmake-helpers: program dependencies - found ZLIB with components",
                                  "cmake-helpers: program dependencies - component ZLIB::ZLIB linked to cmake_helpers_test",
                                  "cmake-helpers: program dependencies - linked ZLIB to cmake_helpers_test"],
                          preset="conan-release")
