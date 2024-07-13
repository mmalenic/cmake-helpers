from subprocess import CalledProcessError, run
from typing import List

import pytest

from tests.fixtures import program_dependencies, run_cmake_with_assert


def default_contains() -> List[str]:
    return ["cmake-helpers: program dependencies - found ZLIB with components",
            "cmake-helpers: program dependencies - component ZLIB::ZLIB linked to cmake_helpers_test",
            "cmake-helpers: program dependencies - linked ZLIB to cmake_helpers_test",
            "cmake-helpers: program dependencies - component zlib_DEPS_TARGET linked to cmake_helpers_test"]


def default_not_contains() -> List[str]:
    return ["cmake-helpers: program dependencies -     visibility =",
            "cmake-helpers: program dependencies -     version ="]


def test_program_dependencies(program_dependencies, capfd):
    """
    Test that program dependencies links components to the project target.
    """
    run_cmake_with_assert(capfd, contains_messages=default_contains(),
                          not_contains_messages=default_not_contains(),
                          preset="conan-release")


def test_program_dependencies_components(program_dependencies, capfd):
    """
    Test that program dependencies links manually specified components to the project target.
    """
    run_cmake_with_assert(capfd, contains_messages=default_contains()[0:3],
                          not_contains_messages=default_not_contains() + [
                              default_contains()[3]],
                          variables={"components": "ZLIB::ZLIB"}, preset="conan-release")


def test_program_dependencies_version(program_dependencies, capfd):
    """
    Test that program dependencies links components to the project target with a version.
    """
    run_cmake_with_assert(capfd, contains_messages=default_contains() + [
        "cmake-helpers: program dependencies -     version = 1.3"],
                          not_contains_messages=[default_not_contains()[0]],
                          variables={"version": "1.3"},
                          preset="conan-release")


def test_program_dependencies_visibility(program_dependencies, capfd):
    """
    Test that program dependencies links components to the project target with a visibility.
    """
    run_cmake_with_assert(capfd, contains_messages=default_contains() +
                                                   ["cmake-helpers: program dependencies -     visibility = PRIVATE"],
                          not_contains_messages=[default_not_contains()[1]],
                          variables={"visibility": "PRIVATE"},
                          preset="conan-release")


def test_program_dependencies_extra_args(program_dependencies, capfd):
    """
    Test that program dependencies links components to the project target with extra find package args.
    """
    run_cmake_with_assert(capfd, contains_messages=default_contains(),
                          not_contains_messages=default_not_contains(),
                          variables={"find_package_args": "QUIET;REQUIRED"},
                          preset="conan-release")


def test_program_dependencies_extra_args_invalid(program_dependencies, capfd):
    """
    Test that program dependencies links components to the project target with invalid extra find package args.
    """
    with pytest.raises(CalledProcessError):
        run_cmake_with_assert(capfd,
                              contains_messages=default_contains(),
                              not_contains_messages=default_not_contains(),
                              variables={"find_package_args": "invalid_arg"},
                              preset="conan-release")
