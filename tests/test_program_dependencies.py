from subprocess import CalledProcessError

import pytest

from tests.fixtures import program_dependencies, conan_profile_detect, conan_install, run_cmake_with_assert


def test_program_dependencies(program_dependencies, capfd):
    """
    Test that check symbols compiles an existing symbol.
    """
    # run_cmake_with_assert(capfd, "cmake-helpers: check_symbol - using check_cxx_symbol_exists")