"""
Tests for add dep function.
"""

from subprocess import CalledProcessError
from typing import List

import pytest

from tests.fixtures import add_dep, run_cmake_with_assert


def default_contains() -> List[str]:
    return [
        "cmake-helpers: helpers_add_dep - found ZLIB with components",
        "cmake-helpers: helpers_add_dep - component ZLIB::ZLIB linked to cmake_helpers_test",
        "cmake-helpers: helpers_add_dep - linked ZLIB to cmake_helpers_test",
        "cmake-helpers: helpers_add_dep - component zlib_DEPS_TARGET linked to cmake_helpers_test",
    ]


def default_not_contains() -> List[str]:
    return [
        "cmake-helpers:                   visibility =",
        "cmake-helpers:                   version =",
    ]


def test_add_dep(add_dep, capfd):
    """
    Test that add dep links components to the project target.
    """
    run_cmake_with_assert(
        capfd,
        contains_messages=default_contains(),
        not_contains_messages=default_not_contains(),
        preset="conan-release",
    )


def test_add_dep_components(add_dep, capfd):
    """
    Test that add dep links manually specified components to the project target.
    """
    run_cmake_with_assert(
        capfd,
        contains_messages=default_contains()[0:3],
        not_contains_messages=default_not_contains() + [default_contains()[3]],
        variables={"components": "ZLIB::ZLIB"},
        preset="conan-release",
    )


def test_add_dep_version(add_dep, capfd):
    """
    Test that add dep links components to the project target with a version.
    """
    run_cmake_with_assert(
        capfd,
        contains_messages=default_contains()
        + ["cmake-helpers:                   version = 1.3"],
        not_contains_messages=[default_not_contains()[0]],
        variables={"version": "1.3"},
        preset="conan-release",
    )


def test_add_dep_visibility(add_dep, capfd):
    """
    Test that add dep links components to the project target with a visibility.
    """
    run_cmake_with_assert(
        capfd,
        contains_messages=default_contains()
        + ["cmake-helpers:                   visibility = PRIVATE"],
        not_contains_messages=[default_not_contains()[1]],
        variables={"visibility": "PRIVATE"},
        preset="conan-release",
    )


def test_add_dep_extra_args(add_dep, capfd):
    """
    Test that add dep links components to the project target with extra find package args.
    """
    run_cmake_with_assert(
        capfd,
        contains_messages=default_contains(),
        not_contains_messages=default_not_contains(),
        variables={"find_package_args": "QUIET;REQUIRED"},
        preset="conan-release",
    )


def test_add_dep_extra_args_invalid(add_dep, capfd):
    """
    Test that add dep links components to the project target with invalid extra find package args.
    """
    with pytest.raises(CalledProcessError):
        run_cmake_with_assert(
            capfd,
            contains_messages=default_contains(),
            not_contains_messages=default_not_contains(),
            variables={"find_package_args": "invalid_arg"},
            preset="conan-release",
        )
